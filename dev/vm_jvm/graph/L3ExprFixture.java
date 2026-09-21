package graph;

/**
 * Expression/call/IF/ARG/recursion fixtures. Callee links are physical {@link L3Node} references.
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


    /** {@code return SEQUENCE(LOCAL_SET(0, 5), LOCAL_GET(0))} → 5. */
    public static L3Node localsSetGet() {
        L3Node set = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 5));
        L3Node get = L3Node.ofInt(L3Role.LOCAL_GET, 0);
        L3Node seq = L3Node.of(L3Role.SEQUENCE, set, get);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, seq));
    }

    /** {@code return SEQUENCE(LOCAL_SET(0,1), LOCAL_SET(0,2), LOCAL_GET(0))} → 2. */
    public static L3Node localsOrderedOverwrite() {
        L3Node s1 = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 1));
        L3Node s2 = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 2));
        L3Node get = L3Node.ofInt(L3Role.LOCAL_GET, 0);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE, s1, s2, get)));
    }

    /** LOCAL_SET RHS is PROBE once; return stored value. */
    public static L3Node localsRhsOnce() {
        L3Node set = new L3Node(L3Role.LOCAL_SET, 0, L3Node.of(L3Role.PROBE));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, set));
    }

    /**
     * Caller: SEQUENCE(LOCAL_SET(0,10), CALL(callee), LOCAL_GET(0)).
     * Callee: LOCAL_SET(0,99) then return 99. Caller local must stay 10.
     */
    public static L3Node localsNestedCallIsolation() {
        L3Node calleeBody = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 99));
        L3Node callee = L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, calleeBody));
        L3Node set = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 10));
        L3Node call = L3Node.of(L3Role.CALL, callee, L3Node.of(L3Role.SUBJECT_REF));
        L3Node get = L3Node.ofInt(L3Role.LOCAL_GET, 0);
        L3Node seq = L3Node.of(L3Role.SEQUENCE, set, call, get);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, seq));
    }

    /**
     * Callee: SEQUENCE(LOCAL_SET(0,0), LOCAL_SET(0, LOCAL_GET(0)+ARG(1)), LOCAL_GET(0)).
     * Two calls with 5 then 7 must yield 5 and 7 (fresh locals each activation).
     */
    public static L3Node calleeFreshLocalsAddArg() {
        L3Node zero = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 0));
        L3Node add = L3Node.of(L3Role.ADD, L3Node.ofInt(L3Role.LOCAL_GET, 0), L3Node.ofInt(L3Role.ARG, 1));
        L3Node set = new L3Node(L3Role.LOCAL_SET, 0, add);
        L3Node get = L3Node.ofInt(L3Role.LOCAL_GET, 0);
        L3Node seq = L3Node.of(L3Role.SEQUENCE, zero, set, get);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, seq));
    }

    /** Entry calling fresh-locals callee twice: return CALL(...,5) + CALL(...,7) → 12. */
    public static L3Node callerTwoFreshLocalCalls() {
        L3Node callee = calleeFreshLocalsAddArg();
        L3Node c1 = L3Node.of(
                L3Role.CALL, callee, L3Node.of(L3Role.SUBJECT_REF), L3Node.ofInt(L3Role.INT_LITERAL, 5));
        L3Node c2 = L3Node.of(
                L3Role.CALL, callee, L3Node.of(L3Role.SUBJECT_REF), L3Node.ofInt(L3Role.INT_LITERAL, 7));
        L3Node add = L3Node.of(L3Role.ADD, c1, c2);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, add));
    }

    public static L3Node localsNegativeGet() {
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.ofInt(L3Role.LOCAL_GET, -1)));
    }

    /** SET slot 0 then GET slot 1 → out of range (slotCount=1). */
    public static L3Node localsOutOfRangeGet() {
        L3Node set = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 1));
        L3Node get = L3Node.ofInt(L3Role.LOCAL_GET, 1);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE, set, get)));
    }

    /** GET without SET → uninitialized (also OOR if slotCount 0 — use SET in untaken IF branch). */
    public static L3Node localsUninitializedGet() {
        // IF(0, LOCAL_SET(0,1), 0) then LOCAL_GET(0): after IF slot not definitely assigned
        L3Node set = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 1));
        L3Node iff = L3Node.of(
                L3Role.IF,
                L3Node.ofInt(L3Role.INT_LITERAL, 0),
                set,
                L3Node.ofInt(L3Role.INT_LITERAL, 0));
        L3Node get = L3Node.ofInt(L3Role.LOCAL_GET, 0);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE, iff, get)));
    }

    public static L3Node localsMalformedSequence() {
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE)));
    }

    public static L3Node localsMalformedSet() {
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.ofInt(L3Role.LOCAL_SET, 0)));
    }

    /** Zero iterations: LOCAL_SET(0,0), WHILE(LOCAL_GET(0), ...), LOCAL_GET(0) → 0. */
    public static L3Node whileZeroIterations() {
        L3Node init = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 0));
        L3Node body = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 99));
        L3Node w = L3Node.of(L3Role.WHILE, L3Node.ofInt(L3Role.LOCAL_GET, 0), body);
        L3Node get = L3Node.ofInt(L3Role.LOCAL_GET, 0);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE, init, w, get)));
    }

    /**
     * Three iterations: n=3; while n: n = n + (-1); result LOCAL_GET(0)==0.
     */
    public static L3Node whileThreeDownToZero() {
        L3Node init = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 3));
        L3Node dec = L3Node.of(
                L3Role.ADD, L3Node.ofInt(L3Role.LOCAL_GET, 0), L3Node.ofInt(L3Role.INT_LITERAL, -1));
        L3Node body = new L3Node(L3Role.LOCAL_SET, 0, dec);
        L3Node w = L3Node.of(L3Role.WHILE, L3Node.ofInt(L3Role.LOCAL_GET, 0), body);
        L3Node get = L3Node.ofInt(L3Role.LOCAL_GET, 0);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE, init, w, get)));
    }

    /**
     * Condition and body each contain PROBE; 3 iters → cond 4 times, body 3 times (total 7).
     * Ends with LOCAL_GET(0)==0.
     */
    public static L3Node whileProbeCondAndBody() {
        L3Node init = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 3));
        L3Node cond = L3Node.of(L3Role.SEQUENCE, L3Node.of(L3Role.PROBE), L3Node.ofInt(L3Role.LOCAL_GET, 0));
        L3Node dec = L3Node.of(
                L3Role.ADD, L3Node.ofInt(L3Role.LOCAL_GET, 0), L3Node.ofInt(L3Role.INT_LITERAL, -1));
        L3Node body = L3Node.of(
                L3Role.SEQUENCE,
                L3Node.of(L3Role.PROBE),
                new L3Node(L3Role.LOCAL_SET, 0, dec));
        L3Node w = L3Node.of(L3Role.WHILE, cond, body);
        L3Node get = L3Node.ofInt(L3Role.LOCAL_GET, 0);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE, init, w, get)));
    }

    /**
     * Caller local 0=10; CALL callee that loops LOCAL_SET(0) down from 3; then LOCAL_GET(0) still 10.
     */
    public static L3Node whileNestedCallIsolation() {
        L3Node callee = whileThreeDownToZero();
        L3Node set = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 10));
        L3Node call = L3Node.of(L3Role.CALL, callee, L3Node.of(L3Role.SUBJECT_REF));
        L3Node get = L3Node.ofInt(L3Role.LOCAL_GET, 0);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE, set, call, get)));
    }

    public static L3Node whileBadArity() {
        L3Node w = L3Node.of(L3Role.WHILE, L3Node.ofInt(L3Role.INT_LITERAL, 1));
        return L3Node.of(
                L3Role.CALLABLE,
                L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE, w, L3Node.ofInt(L3Role.INT_LITERAL, 0))));
    }

    /** WHILE as sole RETURN value — rejected. */
    public static L3Node whileInValueContextReturn() {
        L3Node w = L3Node.of(
                L3Role.WHILE,
                L3Node.ofInt(L3Role.INT_LITERAL, 0),
                L3Node.ofInt(L3Role.INT_LITERAL, 1));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, w));
    }

    /** WHILE as final SEQUENCE child — rejected. */
    public static L3Node whileInFinalSequence() {
        L3Node init = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 0));
        L3Node w = L3Node.of(
                L3Role.WHILE,
                L3Node.ofInt(L3Role.LOCAL_GET, 0),
                L3Node.ofInt(L3Role.INT_LITERAL, 1));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE, init, w)));
    }

    /**
     * Break after 3 iters: while(1) { n=n+1; if (n-3)==0 BREAK else 0 }; result n==3.
     * IF in statement position so BREAK is legal in the else arm.
     */
    public static L3Node breakAfterThree() {
        L3Node init = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 0));
        L3Node incr = new L3Node(
                L3Role.LOCAL_SET,
                0,
                L3Node.of(L3Role.ADD, L3Node.ofInt(L3Role.LOCAL_GET, 0), L3Node.ofInt(L3Role.INT_LITERAL, 1)));
        L3Node condEq3 = L3Node.of(
                L3Role.ADD, L3Node.ofInt(L3Role.LOCAL_GET, 0), L3Node.ofInt(L3Role.INT_LITERAL, -3));
        // cond 0 when n==3 → else BREAK; else then dummy 0
        L3Node iff = L3Node.of(
                L3Role.IF, condEq3, L3Node.ofInt(L3Role.INT_LITERAL, 0), L3Node.of(L3Role.BREAK));
        L3Node body = L3Node.of(L3Role.SEQUENCE, incr, iff);
        L3Node w = L3Node.of(L3Role.WHILE, L3Node.ofInt(L3Role.INT_LITERAL, 1), body);
        L3Node get = L3Node.ofInt(L3Role.LOCAL_GET, 0);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE, init, w, get)));
    }

    /**
     * Continue skips tail: while n>0 { n--; CONTINUE; skipped++ }; skipped stays 0.
     */
    public static L3Node continueSkipsTail() {
        L3Node initN = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 3));
        L3Node initS = new L3Node(L3Role.LOCAL_SET, 1, L3Node.ofInt(L3Role.INT_LITERAL, 0));
        L3Node dec = new L3Node(
                L3Role.LOCAL_SET,
                0,
                L3Node.of(L3Role.ADD, L3Node.ofInt(L3Role.LOCAL_GET, 0), L3Node.ofInt(L3Role.INT_LITERAL, -1)));
        L3Node skipped = new L3Node(
                L3Role.LOCAL_SET,
                1,
                L3Node.of(L3Role.ADD, L3Node.ofInt(L3Role.LOCAL_GET, 1), L3Node.ofInt(L3Role.INT_LITERAL, 1)));
        L3Node body = L3Node.of(
                L3Role.SEQUENCE, dec, L3Node.of(L3Role.CONTINUE), skipped, L3Node.ofInt(L3Role.INT_LITERAL, 0));
        L3Node w = L3Node.of(L3Role.WHILE, L3Node.ofInt(L3Role.LOCAL_GET, 0), body);
        L3Node getS = L3Node.ofInt(L3Role.LOCAL_GET, 1);
        return L3Node.of(
                L3Role.CALLABLE,
                L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE, initN, initS, w, getS)));
    }

    /**
     * Nested: outer n counts; inner breaks immediately; outer continues to 2.
     * Outer while(1): SEQUENCE(incr outer, inner WHILE(1, BREAK), if outer==2 BREAK else 0)
     * Result outer==2. Inner BREAK must not exit outer.
     */
    public static L3Node nestedBreakNearestOnly() {
        L3Node init = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 0));
        L3Node incr = new L3Node(
                L3Role.LOCAL_SET,
                0,
                L3Node.of(L3Role.ADD, L3Node.ofInt(L3Role.LOCAL_GET, 0), L3Node.ofInt(L3Role.INT_LITERAL, 1)));
        L3Node inner = L3Node.of(
                L3Role.WHILE, L3Node.ofInt(L3Role.INT_LITERAL, 1), L3Node.of(L3Role.BREAK));
        L3Node condEq2 = L3Node.of(
                L3Role.ADD, L3Node.ofInt(L3Role.LOCAL_GET, 0), L3Node.ofInt(L3Role.INT_LITERAL, -2));
        L3Node outerBreak = L3Node.of(
                L3Role.IF, condEq2, L3Node.ofInt(L3Role.INT_LITERAL, 0), L3Node.of(L3Role.BREAK));
        L3Node body = L3Node.of(L3Role.SEQUENCE, incr, inner, outerBreak);
        L3Node outer = L3Node.of(L3Role.WHILE, L3Node.ofInt(L3Role.INT_LITERAL, 1), body);
        L3Node get = L3Node.ofInt(L3Role.LOCAL_GET, 0);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE, init, outer, get)));
    }

    /** Code after loop: break once then LOCAL_SET(1,7); result GET(1)==7. */
    public static L3Node codeAfterBreakLoop() {
        L3Node init = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 0));
        L3Node body = L3Node.of(L3Role.BREAK);
        L3Node w = L3Node.of(L3Role.WHILE, L3Node.ofInt(L3Role.INT_LITERAL, 1), body);
        L3Node after = new L3Node(L3Role.LOCAL_SET, 1, L3Node.ofInt(L3Role.INT_LITERAL, 7));
        L3Node get = L3Node.ofInt(L3Role.LOCAL_GET, 1);
        return L3Node.of(
                L3Role.CALLABLE,
                L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE, init, w, after, get)));
    }

    public static L3Node breakOutsideLoop() {
        return L3Node.of(
                L3Role.CALLABLE,
                L3Node.of(
                        L3Role.RETURN,
                        L3Node.of(L3Role.SEQUENCE, L3Node.of(L3Role.BREAK), L3Node.ofInt(L3Role.INT_LITERAL, 0))));
    }

    public static L3Node breakInValueContext() {
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.of(L3Role.BREAK)));
    }

    public static L3Node breakMalformedArity() {
        L3Node bad = L3Node.of(L3Role.BREAK, L3Node.ofInt(L3Role.INT_LITERAL, 0));
        L3Node w = L3Node.of(L3Role.WHILE, L3Node.ofInt(L3Role.INT_LITERAL, 1), bad);
        return L3Node.of(
                L3Role.CALLABLE,
                L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE, w, L3Node.ofInt(L3Role.INT_LITERAL, 0))));
    }

    // ---- Nested RETURN (Path B slice NESTED-RETURN) ----

    /**
     * Nested RETURN in SEQUENCE skips tail: return 42; then PROBE / 0 never run.
     */
    public static L3Node returnSkipsSequenceTail() {
        L3Node early = L3Node.of(L3Role.RETURN, L3Node.ofInt(L3Role.INT_LITERAL, 42));
        L3Node seq = L3Node.of(
                L3Role.SEQUENCE, early, L3Node.of(L3Role.PROBE), L3Node.ofInt(L3Role.INT_LITERAL, 0));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, seq));
    }

    /** Selected IF then-arm RETURN(10); else PROBE not evaluated. */
    public static L3Node returnInSelectedIfArm() {
        L3Node iff = L3Node.of(
                L3Role.IF,
                L3Node.ofInt(L3Role.INT_LITERAL, 1),
                L3Node.of(L3Role.RETURN, L3Node.ofInt(L3Role.INT_LITERAL, 10)),
                L3Node.of(L3Role.PROBE));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, iff));
    }

    /**
     * WHILE body RETURN exits callable (not merely the loop).
     * SEQUENCE(set 1, WHILE(get, RETURN(99)), get) → 99; final get never runs.
     */
    public static L3Node returnFromWhileBody() {
        L3Node init = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 1));
        L3Node body = L3Node.of(L3Role.RETURN, L3Node.ofInt(L3Role.INT_LITERAL, 99));
        L3Node w = L3Node.of(L3Role.WHILE, L3Node.ofInt(L3Role.LOCAL_GET, 0), body);
        L3Node get = L3Node.ofInt(L3Role.LOCAL_GET, 0);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE, init, w, get)));
    }

    /**
     * Callee early-RETURN(7); caller SEQUENCE continues after CALL → 100.
     * Callee: RETURN(SEQUENCE(RETURN(7), PROBE)) — probe in callee must not tick.
     */
    public static L3Node returnInCalleeCallerContinues() {
        L3Node early = L3Node.of(L3Role.RETURN, L3Node.ofInt(L3Role.INT_LITERAL, 7));
        L3Node calleeBody = L3Node.of(L3Role.SEQUENCE, early, L3Node.of(L3Role.PROBE));
        L3Node callee = L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, calleeBody));
        L3Node call = L3Node.of(L3Role.CALL, callee, L3Node.of(L3Role.SUBJECT_REF));
        L3Node after = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 100));
        L3Node get = L3Node.ofInt(L3Role.LOCAL_GET, 0);
        L3Node seq = L3Node.of(L3Role.SEQUENCE, call, after, get);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, seq));
    }

    /**
     * RETURN expression is PROBE exactly once; trailing PROBE skipped.
     * Result == 1, ArgEvalCounter == 1.
     */
    public static L3Node returnExprProbeOnce() {
        L3Node early = L3Node.of(L3Role.RETURN, L3Node.of(L3Role.PROBE));
        L3Node seq = L3Node.of(L3Role.SEQUENCE, early, L3Node.of(L3Role.PROBE));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, seq));
    }

    /**
     * BREAK in callee loop does not cross CALL: caller WHILE continues.
     * Caller: set n=0; while(1){ CALL(callee); n++; if n==2 BREAK else 0 }; get n → 2
     * Callee: while(1) BREAK.
     */
    public static L3Node breakInCalleeDoesNotCrossCall() {
        L3Node callee = L3Node.of(
                L3Role.CALLABLE,
                L3Node.of(
                        L3Role.RETURN,
                        L3Node.of(
                                L3Role.SEQUENCE,
                                L3Node.of(
                                        L3Role.WHILE,
                                        L3Node.ofInt(L3Role.INT_LITERAL, 1),
                                        L3Node.of(L3Role.BREAK)),
                                L3Node.ofInt(L3Role.INT_LITERAL, 0))));
        L3Node call = L3Node.of(L3Role.CALL, callee, L3Node.of(L3Role.SUBJECT_REF));
        L3Node init = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 0));
        L3Node incr = new L3Node(
                L3Role.LOCAL_SET,
                0,
                L3Node.of(L3Role.ADD, L3Node.ofInt(L3Role.LOCAL_GET, 0), L3Node.ofInt(L3Role.INT_LITERAL, 1)));
        L3Node condEq2 = L3Node.of(
                L3Role.ADD, L3Node.ofInt(L3Role.LOCAL_GET, 0), L3Node.ofInt(L3Role.INT_LITERAL, -2));
        L3Node br = L3Node.of(
                L3Role.IF, condEq2, L3Node.ofInt(L3Role.INT_LITERAL, 0), L3Node.of(L3Role.BREAK));
        L3Node body = L3Node.of(L3Role.SEQUENCE, call, incr, br);
        L3Node w = L3Node.of(L3Role.WHILE, L3Node.ofInt(L3Role.INT_LITERAL, 1), body);
        L3Node get = L3Node.ofInt(L3Role.LOCAL_GET, 0);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE, init, w, get)));
    }

    /** RETURN with zero children. */
    public static L3Node returnEmptyArity() {
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN));
    }

    /** Nested RETURN with two value children. */
    public static L3Node returnTwoValues() {
        L3Node bad = L3Node.of(
                L3Role.RETURN,
                L3Node.ofInt(L3Role.INT_LITERAL, 1),
                L3Node.ofInt(L3Role.INT_LITERAL, 2));
        return L3Node.of(
                L3Role.CALLABLE,
                L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE, bad, L3Node.ofInt(L3Role.INT_LITERAL, 0))));
    }

    /** RETURN value is SUBJECT_REF (not an int). */
    public static L3Node returnNonIntValue() {
        L3Node bad = L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SUBJECT_REF));
        return L3Node.of(
                L3Role.CALLABLE,
                L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE, bad, L3Node.ofInt(L3Role.INT_LITERAL, 0))));
    }

    /** CALLABLE body is SEQUENCE (not RETURN) — RETURN outside callable wrapper. */
    public static L3Node returnOutsideCallableBody() {
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.SEQUENCE, L3Node.ofInt(L3Role.INT_LITERAL, 1)));
    }


    // ---- Recursive / mutual CALL (Path B slice RECURSIVE-CALL / 88) ----

    /**
     * Self-recursive countdown: {@code f(n) = n==0 ? 0 : 1+f(n-1)} → returns n.
     * Built with {@link L3Node#unsealedCallable()} + seal for physical self-CALL.
     */
    public static L3Node recursiveCountdown() {
        L3Node self = L3Node.unsealedCallable();
        L3Node n = L3Node.ofInt(L3Role.ARG, 1);
        L3Node dec = L3Node.of(L3Role.ADD, n, L3Node.ofInt(L3Role.INT_LITERAL, -1));
        L3Node rec = L3Node.of(
                L3Role.CALL, self, L3Node.ofInt(L3Role.ARG, 0), dec);
        L3Node onePlus = L3Node.of(L3Role.ADD, L3Node.ofInt(L3Role.INT_LITERAL, 1), rec);
        L3Node iff = L3Node.of(
                L3Role.IF, L3Node.ofInt(L3Role.ARG, 1), onePlus, L3Node.ofInt(L3Role.INT_LITERAL, 0));
        self.seal(L3Node.of(L3Role.RETURN, iff));
        // Entry arity-1 wrapper: CALL(self, subject, subject[0]) — field0 is the count
        L3Node subject = L3Node.of(L3Role.SUBJECT_REF);
        L3Node field0 = new L3Node(L3Role.FIELD_FOLLOW, 0, subject);
        L3Node call = L3Node.of(L3Role.CALL, self, L3Node.of(L3Role.SUBJECT_REF), field0);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, call));
    }

    /**
     * Self-recursive base returns literal depth seed via nested RETURN:
     * {@code f(n) = n==0 ? RETURN(7) : f(n-1)} → 7. Nested RETURN at base.
     */
    public static L3Node recursiveNestedReturnAtBase() {
        L3Node self = L3Node.unsealedCallable();
        L3Node n = L3Node.ofInt(L3Role.ARG, 1);
        L3Node dec = L3Node.of(L3Role.ADD, n, L3Node.ofInt(L3Role.INT_LITERAL, -1));
        L3Node rec = L3Node.of(
                L3Role.CALL, self, L3Node.ofInt(L3Role.ARG, 0), dec);
        L3Node base = L3Node.of(L3Role.RETURN, L3Node.ofInt(L3Role.INT_LITERAL, 7));
        // SEQUENCE so nested RETURN is not the sole root wrapper expression alone —
        // IF then-arm is recursive CALL; else-arm is nested RETURN(7)
        L3Node iff = L3Node.of(L3Role.IF, L3Node.ofInt(L3Role.ARG, 1), rec, base);
        self.seal(L3Node.of(L3Role.RETURN, iff));
        L3Node field0 = new L3Node(L3Role.FIELD_FOLLOW, 0, L3Node.of(L3Role.SUBJECT_REF));
        L3Node call = L3Node.of(L3Role.CALL, self, L3Node.of(L3Role.SUBJECT_REF), field0);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, call));
    }

    /**
     * Mutual even/odd: even(n)= n==0?1:odd(n-1); odd(n)= n==0?0:even(n-1).
     * Entry calls even(subject[0]).
     */
    public static L3Node mutualEvenOdd() {
        L3Node even = L3Node.unsealedCallable();
        L3Node odd = L3Node.unsealedCallable();
        L3Node evenDec = L3Node.of(
                L3Role.ADD, L3Node.ofInt(L3Role.ARG, 1), L3Node.ofInt(L3Role.INT_LITERAL, -1));
        L3Node oddDec = L3Node.of(
                L3Role.ADD, L3Node.ofInt(L3Role.ARG, 1), L3Node.ofInt(L3Role.INT_LITERAL, -1));
        L3Node callOdd = L3Node.of(
                L3Role.CALL, odd, L3Node.ofInt(L3Role.ARG, 0), evenDec);
        L3Node callEven = L3Node.of(
                L3Role.CALL, even, L3Node.ofInt(L3Role.ARG, 0), oddDec);
        L3Node evenBody = L3Node.of(
                L3Role.IF,
                L3Node.ofInt(L3Role.ARG, 1),
                callOdd,
                L3Node.ofInt(L3Role.INT_LITERAL, 1));
        L3Node oddBody = L3Node.of(
                L3Role.IF,
                L3Node.ofInt(L3Role.ARG, 1),
                callEven,
                L3Node.ofInt(L3Role.INT_LITERAL, 0));
        even.seal(L3Node.of(L3Role.RETURN, evenBody));
        odd.seal(L3Node.of(L3Role.RETURN, oddBody));
        L3Node field0 = new L3Node(L3Role.FIELD_FOLLOW, 0, L3Node.of(L3Role.SUBJECT_REF));
        L3Node call = L3Node.of(L3Role.CALL, even, L3Node.of(L3Role.SUBJECT_REF), field0);
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, call));
    }

    /**
     * Recursive fresh-local isolation:
     * {@code f(n) = SEQUENCE(LOCAL_SET(0, ARG(1)), n==0 ? LOCAL_GET(0) : f(n-1))}
     * Each activation writes its own n into slot 0; deepest returns 0; caller slots untouched.
     * Entry: SEQUENCE(LOCAL_SET(0, 99), CALL(f, subject, 3), LOCAL_GET(0)) → 99.
     */
    public static L3Node recursiveFreshLocalIsolation() {
        L3Node self = L3Node.unsealedCallable();
        L3Node setN = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.ARG, 1));
        L3Node dec = L3Node.of(
                L3Role.ADD, L3Node.ofInt(L3Role.ARG, 1), L3Node.ofInt(L3Role.INT_LITERAL, -1));
        L3Node rec = L3Node.of(
                L3Role.CALL, self, L3Node.ofInt(L3Role.ARG, 0), dec);
        L3Node base = L3Node.ofInt(L3Role.LOCAL_GET, 0);
        L3Node iff = L3Node.of(L3Role.IF, L3Node.ofInt(L3Role.ARG, 1), rec, base);
        L3Node body = L3Node.of(L3Role.SEQUENCE, setN, iff);
        self.seal(L3Node.of(L3Role.RETURN, body));
        L3Node callerSet = new L3Node(L3Role.LOCAL_SET, 0, L3Node.ofInt(L3Role.INT_LITERAL, 99));
        L3Node call = L3Node.of(
                L3Role.CALL,
                self,
                L3Node.of(L3Role.SUBJECT_REF),
                L3Node.ofInt(L3Role.INT_LITERAL, 3));
        L3Node get = L3Node.ofInt(L3Role.LOCAL_GET, 0);
        return L3Node.of(
                L3Role.CALLABLE,
                L3Node.of(L3Role.RETURN, L3Node.of(L3Role.SEQUENCE, callerSet, call, get)));
    }

    /**
     * Self-recursive entry with an unreachable sealed orphan CALLABLE (not linked).
     */
    public static CallGraphWithOrphan recursiveWithUnreachableOrphan() {
        L3Node entry = recursiveCountdown();
        L3Node orphan = L3Node.unsealedCallable();
        orphan.seal(L3Node.of(L3Role.RETURN, L3Node.ofInt(L3Role.INT_LITERAL, 1)));
        return new CallGraphWithOrphan(entry, orphan);
    }

    /** Entry is unsealed CALLABLE — must reject before emit. */
    public static L3Node unsealedEntryCallable() {
        return L3Node.unsealedCallable();
    }

    /** Sealed entry CALLs an unsealed callee. */
    public static L3Node callUnsealedCallee() {
        L3Node unsealed = L3Node.unsealedCallable();
        L3Node call = L3Node.of(L3Role.CALL, unsealed, L3Node.of(L3Role.SUBJECT_REF));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, call));
    }

    /** Self-recursive CALL with arity mismatch (self arity 2, call passes only subject). */
    public static L3Node recursiveArityMismatch() {
        L3Node self = L3Node.unsealedCallable();
        L3Node body = L3Node.of(
                L3Role.IF,
                L3Node.ofInt(L3Role.ARG, 1),
                L3Node.of(L3Role.CALL, self, L3Node.ofInt(L3Role.ARG, 0)),
                L3Node.ofInt(L3Role.INT_LITERAL, 0));
        self.seal(L3Node.of(L3Role.RETURN, body));
        L3Node call = L3Node.of(
                L3Role.CALL,
                self,
                L3Node.of(L3Role.SUBJECT_REF),
                L3Node.ofInt(L3Role.INT_LITERAL, 1));
        return L3Node.of(L3Role.CALLABLE, L3Node.of(L3Role.RETURN, call));
    }

    /**
     * Malformed structural cycle: CALLABLE sealed with RETURN whose value child is the
     * CALLABLE itself (owned-tree cycle, not a CALL reference edge). Walk terminates via
     * IdentityHashMap, but validation rejects non-int / wrong role as value.
     */
    public static L3Node malformedOwnedCallableCycle() {
        L3Node self = L3Node.unsealedCallable();
        self.seal(L3Node.of(L3Role.RETURN, self));
        return self;
    }

    /** Double-seal helper for negative smoke (returns the shell after first seal). */
    public static L3Node sealedShellForDoubleSeal() {
        L3Node self = L3Node.unsealedCallable();
        self.seal(L3Node.of(L3Role.RETURN, L3Node.ofInt(L3Role.INT_LITERAL, 0)));
        return self;
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
