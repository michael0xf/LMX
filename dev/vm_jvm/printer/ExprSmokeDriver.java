package printer;

import graph.ArgEvalCounter;
import graph.L3ExprFixture;
import graph.L3Node;
import lmx.LmxOccurrence;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public final class ExprSmokeDriver {
    private static int checks;
    private static int fails;

    public static void main(String[] args) throws Exception {
        checks = 0;
        fails = 0;

        testUnsupportedRejected();
        testBadArityRejected();
        testBadCalleeRejected();
        testCallAddReturn();
        testSubjectIdentityAcrossCall();
        testUnreachableNotEmitted();

        testIfTrueFalseLiterals();
        testIfUntakenBranchNotEvaluated();
        testIfNestedCall();
        testIfBadArityRejected();
        testIfBadConditionRejected();

        testDirectArgReturn();
        testTwoArgsAdd();
        testNestedComputedArgs();
        testArgSubjectIdentity();
        testArgCountRejected();
        testArgOutOfRangeRejected();
        testProbeOnceLeftToRight();

        testLocalsSetGet();
        testLocalsOrderedOverwrite();
        testLocalsRhsOnce();
        testLocalsNestedCallIsolation();
        testLocalsTwoFreshCalls();
        testLocalsRejected();

        testWhileZeroIterations();
        testWhileThreeDownToZero();
        testWhileProbeCounts();
        testWhileNestedCallIsolation();
        testWhileRejected();

        testBreakAfterThree();
        testContinueSkipsTail();
        testNestedBreakNearestOnly();
        testCodeAfterBreakLoop();
        testBreakContinueRejected();

        testReturnSkipsSequenceTail();
        testReturnInSelectedIfArm();
        testReturnFromWhileBody();
        testReturnInCalleeCallerContinues();
        testReturnExprProbeOnce();
        testBreakInCalleeDoesNotCrossCall();
        testReturnRejected();

        testRecursiveCountdown();
        testMutualEvenOdd();
        testRecursiveFreshLocalIsolation();
        testRecursiveNestedReturnAtBase();
        testRecursiveUnreachableNotEmitted();
        testRecursiveRejected();

        testSealFreezeChildren();

        testOwnershipCycleGuard();

        testRedo();

        testPhysicalLoopLabels();

        testRetryableLocal();
        testUntil();

        if (fails != 0) {
            System.out.println("FAIL ExprSmokeDriver checks=" + checks + " failures=" + fails);
            System.exit(1);
        }
        System.out.println("PASS ExprSmokeDriver checks=" + checks + " failures=0");
    }

    private static void testUnsupportedRejected() {
        boolean threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.unsupportedRoleGraph());
        } catch (IllegalArgumentException e) {
            threw = true;
        }
        check("unsupported role rejected", threw);
    }

    private static void testBadArityRejected() {
        boolean threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.callBadArity());
        } catch (IllegalArgumentException e) {
            threw = true;
        }
        check("bad CALL arity rejected", threw);
    }

    private static void testBadCalleeRejected() {
        boolean threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.callBadCallee());
        } catch (IllegalArgumentException e) {
            threw = true;
        }
        check("bad CALL callee rejected", threw);
    }

    private static void testCallAddReturn() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.callerAddCallPlus5());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        LmxOccurrence subject = LmxOccurrence.independent(Integer.valueOf(10));
        Object result = eval.invoke(null, subject);
        check("call+add+return 10+5=15", Integer.valueOf(15).equals(result));
        check("c0 and c1 both present", hasMethods(cls, "c0", "c1", "eval"));
    }

    private static void testSubjectIdentityAcrossCall() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.callerAddCallPlus5());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Integer cell = Integer.valueOf(7);
        LmxOccurrence subject = LmxOccurrence.independent(cell);
        Object r1 = eval.invoke(null, subject);
        check("first eval 7+5=12", Integer.valueOf(12).equals(r1));
        check("same cell after call", subject.child(0) == cell);
        Object r2 = eval.invoke(null, subject);
        check("second eval still 12", Integer.valueOf(12).equals(r2));
        check("still same cell", subject.child(0) == cell);
    }

    private static void testUnreachableNotEmitted() throws Exception {
        L3ExprFixture.CallGraphWithOrphan g = L3ExprFixture.callerWithUnreachableOrphan();
        List<String> planned = L3ClassfilePrinter.plannedMethodNames(g.entry);
        check("planned has c0 c1 eval", planned.contains("c0") && planned.contains("c1") && planned.contains("eval"));
        check("planned size 3 (no orphan method)", planned.size() == 3);

        Class<?> cls = loadPrinted(g.entry);
        Set<String> names = new HashSet<String>();
        for (Method m : cls.getDeclaredMethods()) {
            names.add(m.getName());
        }
        check("runtime methods c0 c1 eval only", names.equals(new HashSet<String>(Arrays.asList("c0", "c1", "eval"))));
        check("orphan is CALLABLE but unreachable", g.orphan.role == graph.L3Role.CALLABLE && g.orphan != g.entry);
    }

    private static void testIfTrueFalseLiterals() throws Exception {
        Class<?> t = loadPrinted(L3ExprFixture.ifLiteralBranches(1, 10, 20));
        Method evalT = t.getMethod("eval", LmxOccurrence.class);
        Object rt = evalT.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("IF true selects then=10", Integer.valueOf(10).equals(rt));

        Class<?> f = loadPrinted(L3ExprFixture.ifLiteralBranches(0, 10, 20));
        Method evalF = f.getMethod("eval", LmxOccurrence.class);
        Object rf = evalF.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("IF false selects else=20", Integer.valueOf(20).equals(rf));
    }

    private static void testIfUntakenBranchNotEvaluated() throws Exception {
        Class<?> t = loadPrinted(L3ExprFixture.ifTrueUntakenElseInvalid());
        Method evalT = t.getMethod("eval", LmxOccurrence.class);
        LmxOccurrence subT = LmxOccurrence.independent(Integer.valueOf(1), "boom");
        Object rt = evalT.invoke(null, subT);
        check("IF true untaken else not evaluated -> 42", Integer.valueOf(42).equals(rt));

        Class<?> f = loadPrinted(L3ExprFixture.ifFalseUntakenThenInvalid());
        Method evalF = f.getMethod("eval", LmxOccurrence.class);
        LmxOccurrence subF = LmxOccurrence.independent(Integer.valueOf(0), "boom");
        Object rf = evalF.invoke(null, subF);
        check("IF false untaken then not evaluated -> 7", Integer.valueOf(7).equals(rf));
    }

    private static void testIfNestedCall() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.ifNestedCallThen());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        LmxOccurrence subject = LmxOccurrence.independent(Integer.valueOf(3));
        Object r = eval.invoke(null, subject);
        check("IF selects nested CALL -> 3", Integer.valueOf(3).equals(r));
        check("nested CALL emits c0 c1", hasMethods(cls, "c0", "c1", "eval"));
    }

    private static void testIfBadArityRejected() {
        boolean threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.ifBadArity());
        } catch (IllegalArgumentException e) {
            threw = true;
        }
        check("IF bad arity rejected", threw);
    }

    private static void testIfBadConditionRejected() {
        boolean threwSub = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.ifBadConditionSubjectRef());
        } catch (IllegalArgumentException e) {
            threwSub = true;
        }
        check("IF SUBJECT_REF condition rejected", threwSub);

        boolean threwUn = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.ifBadConditionUnsupported());
        } catch (IllegalArgumentException e) {
            threwUn = true;
        }
        check("IF UNSUPPORTED condition rejected", threwUn);
    }

    private static void testDirectArgReturn() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.callerDirectArgReturn());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("direct ARG(1) return 42", Integer.valueOf(42).equals(r));
    }

    private static void testTwoArgsAdd() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.callerTwoArgsAdd());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("two args add 3+4=7", Integer.valueOf(7).equals(r));
    }

    private static void testNestedComputedArgs() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.callerNestedComputedArgs());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("nested computed args (1+2)+10=13", Integer.valueOf(13).equals(r));
    }

    private static void testArgSubjectIdentity() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.callerArgSubjectIdentity());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Integer cell = Integer.valueOf(11);
        LmxOccurrence subject = LmxOccurrence.independent(cell);
        Object r = eval.invoke(null, subject);
        check("ARG(0) field follow returns 11", Integer.valueOf(11).equals(r));
        check("same subject cell no copy", subject.child(0) == cell);
    }

    private static void testArgCountRejected() {
        boolean miss = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.callMissingArg());
        } catch (IllegalArgumentException e) {
            miss = true;
        }
        check("missing CALL arg rejected", miss);

        boolean extra = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.callExtraArg());
        } catch (IllegalArgumentException e) {
            extra = true;
        }
        check("extra CALL arg rejected", extra);
    }

    private static void testArgOutOfRangeRejected() {
        boolean threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.argOutOfRangeNegative());
        } catch (IllegalArgumentException e) {
            threw = true;
        }
        check("ARG(-1) rejected", threw);
    }

    private static void testProbeOnceLeftToRight() throws Exception {
        ArgEvalCounter.reset();
        Class<?> cls = loadPrinted(L3ExprFixture.callerProbeArgOrder());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        ArgEvalCounter.reset();
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        // first PROBE -> 1, second PROBE -> 2, callee returns 1+2=3
        check("probe args sum 1+2=3", Integer.valueOf(3).equals(r));
        check("probe ticks exactly twice", ArgEvalCounter.get() == 2);
    }


    private static void testLocalsSetGet() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.localsSetGet());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("locals set/get -> 5", Integer.valueOf(5).equals(r));
    }

    private static void testLocalsOrderedOverwrite() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.localsOrderedOverwrite());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("locals overwrite -> 2", Integer.valueOf(2).equals(r));
    }

    private static void testLocalsRhsOnce() throws Exception {
        ArgEvalCounter.reset();
        Class<?> cls = loadPrinted(L3ExprFixture.localsRhsOnce());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        ArgEvalCounter.reset();
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("LOCAL_SET RHS probe once yields 1", Integer.valueOf(1).equals(r));
        check("probe ticks exactly once for LOCAL_SET RHS", ArgEvalCounter.get() == 1);
    }

    private static void testLocalsNestedCallIsolation() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.localsNestedCallIsolation());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("nested CALL does not overwrite caller local -> 10", Integer.valueOf(10).equals(r));
    }

    private static void testLocalsTwoFreshCalls() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.callerTwoFreshLocalCalls());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("two calls fresh locals 5+7=12", Integer.valueOf(12).equals(r));
    }

    private static void testLocalsRejected() {
        boolean neg = false;
        try { L3ClassfilePrinter.emitCallable(L3ExprFixture.localsNegativeGet()); }
        catch (IllegalArgumentException e) { neg = true; }
        check("LOCAL_GET negative rejected", neg);

        boolean oor = false;
        try { L3ClassfilePrinter.emitCallable(L3ExprFixture.localsOutOfRangeGet()); }
        catch (IllegalArgumentException e) { oor = true; }
        check("LOCAL_GET out of range rejected", oor);

        boolean uninit = false;
        try { L3ClassfilePrinter.emitCallable(L3ExprFixture.localsUninitializedGet()); }
        catch (IllegalArgumentException e) { uninit = true; }
        check("LOCAL_GET uninitialized rejected", uninit);

        boolean seq = false;
        try { L3ClassfilePrinter.emitCallable(L3ExprFixture.localsMalformedSequence()); }
        catch (IllegalArgumentException e) { seq = true; }
        check("empty SEQUENCE rejected", seq);

        boolean set = false;
        try { L3ClassfilePrinter.emitCallable(L3ExprFixture.localsMalformedSet()); }
        catch (IllegalArgumentException e) { set = true; }
        check("LOCAL_SET without RHS rejected", set);
    }

    private static void testWhileZeroIterations() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.whileZeroIterations());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("WHILE zero iterations -> 0", Integer.valueOf(0).equals(r));
    }

    private static void testWhileThreeDownToZero() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.whileThreeDownToZero());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("WHILE three iters end at 0", Integer.valueOf(0).equals(r));
    }

    private static void testWhileProbeCounts() throws Exception {
        ArgEvalCounter.reset();
        Class<?> cls = loadPrinted(L3ExprFixture.whileProbeCondAndBody());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        ArgEvalCounter.reset();
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("WHILE probe loop ends 0", Integer.valueOf(0).equals(r));
        // cond 4x + body 3x
        check("WHILE cond+body probes == 7", ArgEvalCounter.get() == 7);
    }

    private static void testWhileNestedCallIsolation() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.whileNestedCallIsolation());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("WHILE in callee leaves caller local 10", Integer.valueOf(10).equals(r));
    }

    private static void testWhileRejected() {
        boolean arity = false;
        try { L3ClassfilePrinter.emitCallable(L3ExprFixture.whileBadArity()); }
        catch (IllegalArgumentException e) { arity = true; }
        check("WHILE bad arity rejected", arity);

        boolean val = false;
        try { L3ClassfilePrinter.emitCallable(L3ExprFixture.whileInValueContextReturn()); }
        catch (IllegalArgumentException e) { val = true; }
        check("WHILE in RETURN value context rejected", val);

        boolean fin = false;
        try { L3ClassfilePrinter.emitCallable(L3ExprFixture.whileInFinalSequence()); }
        catch (IllegalArgumentException e) { fin = true; }
        check("WHILE as final SEQUENCE rejected", fin);
    }

    private static void testBreakAfterThree() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.breakAfterThree());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("BREAK after 3 iters -> 3", Integer.valueOf(3).equals(r));
    }

    private static void testContinueSkipsTail() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.continueSkipsTail());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("CONTINUE skips tail skipped==0", Integer.valueOf(0).equals(r));
    }

    private static void testNestedBreakNearestOnly() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.nestedBreakNearestOnly());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("nested BREAK affects nearest only -> 2", Integer.valueOf(2).equals(r));
    }

    private static void testCodeAfterBreakLoop() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.codeAfterBreakLoop());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("code after BREAK loop -> 7", Integer.valueOf(7).equals(r));
    }

    private static void testBreakContinueRejected() {
        boolean out = false;
        try { L3ClassfilePrinter.emitCallable(L3ExprFixture.breakOutsideLoop()); }
        catch (IllegalArgumentException e) { out = true; }
        check("BREAK outside loop rejected", out);

        boolean val = false;
        try { L3ClassfilePrinter.emitCallable(L3ExprFixture.breakInValueContext()); }
        catch (IllegalArgumentException e) { val = true; }
        check("BREAK in value context rejected", val);

        boolean mal = false;
        try { L3ClassfilePrinter.emitCallable(L3ExprFixture.breakMalformedArity()); }
        catch (IllegalArgumentException e) { mal = true; }
        check("BREAK malformed arity rejected", mal);
    }

    private static void testReturnSkipsSequenceTail() throws Exception {
        ArgEvalCounter.reset();
        Class<?> cls = loadPrinted(L3ExprFixture.returnSkipsSequenceTail());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("RETURN skips SEQUENCE tail -> 42", Integer.valueOf(42).equals(r));
        check("RETURN skips SEQUENCE tail probe==0", ArgEvalCounter.get() == 0);
    }

    private static void testReturnInSelectedIfArm() throws Exception {
        ArgEvalCounter.reset();
        Class<?> cls = loadPrinted(L3ExprFixture.returnInSelectedIfArm());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("RETURN in selected IF arm -> 10", Integer.valueOf(10).equals(r));
        check("RETURN IF untaken PROBE not run", ArgEvalCounter.get() == 0);
    }

    private static void testReturnFromWhileBody() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.returnFromWhileBody());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("RETURN from WHILE body exits callable -> 99", Integer.valueOf(99).equals(r));
    }

    private static void testReturnInCalleeCallerContinues() throws Exception {
        ArgEvalCounter.reset();
        Class<?> cls = loadPrinted(L3ExprFixture.returnInCalleeCallerContinues());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("RETURN in callee; caller continues -> 100", Integer.valueOf(100).equals(r));
        check("callee RETURN skips its PROBE", ArgEvalCounter.get() == 0);
    }

    private static void testReturnExprProbeOnce() throws Exception {
        ArgEvalCounter.reset();
        Class<?> cls = loadPrinted(L3ExprFixture.returnExprProbeOnce());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("RETURN expr PROBE once yields 1", Integer.valueOf(1).equals(r));
        check("RETURN expr PROBE ticks exactly once", ArgEvalCounter.get() == 1);
    }

    private static void testBreakInCalleeDoesNotCrossCall() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.breakInCalleeDoesNotCrossCall());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("BREAK in callee does not cross CALL -> 2", Integer.valueOf(2).equals(r));
    }

    private static void testReturnRejected() {
        boolean empty = false;
        try { L3ClassfilePrinter.emitCallable(L3ExprFixture.returnEmptyArity()); }
        catch (IllegalArgumentException e) { empty = true; }
        check("RETURN empty arity rejected", empty);

        boolean two = false;
        try { L3ClassfilePrinter.emitCallable(L3ExprFixture.returnTwoValues()); }
        catch (IllegalArgumentException e) { two = true; }
        check("RETURN two values rejected", two);

        boolean nonInt = false;
        try { L3ClassfilePrinter.emitCallable(L3ExprFixture.returnNonIntValue()); }
        catch (IllegalArgumentException e) { nonInt = true; }
        check("RETURN non-int value rejected", nonInt);

        boolean outside = false;
        try { L3ClassfilePrinter.emitCallable(L3ExprFixture.returnOutsideCallableBody()); }
        catch (IllegalArgumentException e) { outside = true; }
        check("RETURN outside callable body rejected", outside);
    }


    private static void testRecursiveCountdown() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.recursiveCountdown());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r0 = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("recursive countdown base 0 -> 0", Integer.valueOf(0).equals(r0));
        Object r5 = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(5)));
        check("recursive countdown 5 -> 5", Integer.valueOf(5).equals(r5));
        Integer cell = Integer.valueOf(4);
        LmxOccurrence subject = LmxOccurrence.independent(cell);
        Object r4 = eval.invoke(null, subject);
        check("recursive countdown 4 -> 4", Integer.valueOf(4).equals(r4));
        check("recursive countdown subject identity", subject.child(0) == cell);
        check("recursive countdown emits c0 c1", hasMethods(cls, "c0", "c1", "eval"));
    }

    private static void testMutualEvenOdd() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.mutualEvenOdd());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object e0 = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("mutual even(0) -> 1", Integer.valueOf(1).equals(e0));
        Object e4 = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(4)));
        check("mutual even(4) -> 1", Integer.valueOf(1).equals(e4));
        Object e5 = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(5)));
        check("mutual even(5) -> 0", Integer.valueOf(0).equals(e5));
        check("mutual even/odd emits c0 c1 c2", hasMethods(cls, "c0", "c1", "c2", "eval"));
    }

    private static void testRecursiveFreshLocalIsolation() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.recursiveFreshLocalIsolation());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("recursive fresh locals leave caller slot 99", Integer.valueOf(99).equals(r));
    }

    private static void testRecursiveNestedReturnAtBase() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.recursiveNestedReturnAtBase());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(3)));
        check("recursive nested RETURN at base -> 7", Integer.valueOf(7).equals(r));
        Object r0 = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(0)));
        check("recursive nested RETURN base-zero -> 7", Integer.valueOf(7).equals(r0));
    }

    private static void testRecursiveUnreachableNotEmitted() throws Exception {
        L3ExprFixture.CallGraphWithOrphan g = L3ExprFixture.recursiveWithUnreachableOrphan();
        List<String> planned = L3ClassfilePrinter.plannedMethodNames(g.entry);
        // entry + self-recursive callee = c0,c1 (+eval)
        check("recursive planned size 3 (no orphan)", planned.size() == 3);
        Class<?> cls = loadPrinted(g.entry);
        Set<String> names = new HashSet<String>();
        for (Method m : cls.getDeclaredMethods()) {
            names.add(m.getName());
        }
        check(
                "recursive runtime methods c0 c1 eval only",
                names.equals(new HashSet<String>(Arrays.asList("c0", "c1", "eval"))));
        check("recursive orphan sealed but unreachable", g.orphan.isSealed() && g.orphan != g.entry);
    }

    private static void testRecursiveRejected() {
        boolean unsealedEntry = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.unsealedEntryCallable());
        } catch (IllegalStateException e) {
            unsealedEntry = true;
        } catch (IllegalArgumentException e) {
            unsealedEntry = true;
        }
        check("unsealed entry CALLABLE rejected", unsealedEntry);

        boolean unsealedCallee = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.callUnsealedCallee());
        } catch (IllegalStateException e) {
            unsealedCallee = true;
        } catch (IllegalArgumentException e) {
            unsealedCallee = true;
        }
        check("unsealed CALL callee rejected", unsealedCallee);

        boolean arity = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.recursiveArityMismatch());
        } catch (IllegalArgumentException e) {
            arity = true;
        }
        check("recursive CALL arity mismatch rejected", arity);

        boolean owned = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.malformedOwnedCallableCycle());
        } catch (IllegalArgumentException e) {
            owned = true;
        } catch (IllegalStateException e) {
            owned = true;
        }
        check("malformed owned CALLABLE cycle rejected", owned);

        boolean nonCallable = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.callBadCallee());
        } catch (IllegalArgumentException e) {
            nonCallable = true;
        }
        check("recursive suite non-callable target rejected", nonCallable);

        boolean doubleSeal = false;
        try {
            L3Node shell = L3ExprFixture.sealedShellForDoubleSeal();
            shell.seal(L3Node.of(graph.L3Role.RETURN, L3Node.ofInt(graph.L3Role.INT_LITERAL, 1)));
        } catch (IllegalStateException e) {
            doubleSeal = true;
        }
        check("double-seal rejected", doubleSeal);
    }







    private static void testUntil() throws Exception {
        Class<?> c1 = loadPrinted(L3ExprFixture.untilInitialTrueRunsOnce());
        Object r1 = c1.getMethod("eval", lmx.LmxOccurrence.class)
                .invoke(null, lmx.LmxOccurrence.independent(Integer.valueOf(0)));
        check("UNTIL initial-true still runs body once -> 1", Integer.valueOf(1).equals(r1));

        Class<?> c2 = loadPrinted(L3ExprFixture.untilFalseRepeatsThenExits());
        Object r2 = c2.getMethod("eval", lmx.LmxOccurrence.class)
                .invoke(null, lmx.LmxOccurrence.independent(Integer.valueOf(0)));
        check("UNTIL false repeats then exits -> 3", Integer.valueOf(3).equals(r2));

        Class<?> c3 = loadPrinted(L3ExprFixture.untilContinueChecksPostcondition());
        Object r3 = c3.getMethod("eval", lmx.LmxOccurrence.class)
                .invoke(null, lmx.LmxOccurrence.independent(Integer.valueOf(0)));
        check("UNTIL CONTINUE checks postcondition -> 2", Integer.valueOf(2).equals(r3));

        ArgEvalCounter.reset();
        Class<?> c4 = loadPrinted(L3ExprFixture.untilRedoSkipsPostcondition());
        Object r4 = c4.getMethod("eval", lmx.LmxOccurrence.class)
                .invoke(null, lmx.LmxOccurrence.independent(Integer.valueOf(0)));
        check("UNTIL REDO skips postcondition -> n==2", Integer.valueOf(2).equals(r4));
        check("UNTIL REDO skips postcondition probe ticks 1", ArgEvalCounter.get() == 1);

        Class<?> c5 = loadPrinted(L3ExprFixture.untilNearestNestingWithWhile());
        Object r5 = c5.getMethod("eval", lmx.LmxOccurrence.class)
                .invoke(null, lmx.LmxOccurrence.independent(Integer.valueOf(0)));
        check("UNTIL nearest nesting with WHILE -> 1", Integer.valueOf(1).equals(r5));

        Class<?> c6 = loadPrinted(L3ExprFixture.labelledBreakToOuterUntil());
        Object r6 = c6.getMethod("eval", lmx.LmxOccurrence.class)
                .invoke(null, lmx.LmxOccurrence.independent(Integer.valueOf(0)));
        check("labelled BREAK to outer UNTIL -> 1", Integer.valueOf(1).equals(r6));

        boolean threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.untilBadArity());
        } catch (IllegalArgumentException e) {
            threw = e.getMessage() != null && e.getMessage().contains("UNTIL arity");
        }
        check("UNTIL bad arity rejected", threw);

        threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.untilInValueContextReturn());
        } catch (IllegalArgumentException e) {
            threw = e.getMessage() != null && e.getMessage().contains("value context");
        }
        check("UNTIL in value context rejected", threw);

        threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.untilWithRetryLabel());
        } catch (IllegalArgumentException e) {
            threw = e.getMessage() != null && (
                    e.getMessage().contains("LOOP_LABEL") || e.getMessage().contains("RETRY_LABEL"));
        }
        check("RETRY_LABEL as UNTIL label rejected", threw);
    }

    private static void testRetryableLocal() throws Exception {
        ArgEvalCounter.reset();
        Class<?> c1 = loadPrinted(L3ExprFixture.retryLocalsPersistAndProbeNotRolledBack());
        Object n = c1.getMethod("eval", lmx.LmxOccurrence.class)
                .invoke(null, lmx.LmxOccurrence.independent(Integer.valueOf(0)));
        check("RETRY locals persist -> n==2", Integer.valueOf(2).equals(n));
        check("RETRY does not roll back PROBE (ticks 2)", ArgEvalCounter.get() == 2);

        Class<?> c2 = loadPrinted(L3ExprFixture.retryNearestNested());
        Object o = c2.getMethod("eval", lmx.LmxOccurrence.class)
                .invoke(null, lmx.LmxOccurrence.independent(Integer.valueOf(0)));
        check("RETRY nearest nested -> outer==1", Integer.valueOf(1).equals(o));

        Class<?> c3 = loadPrinted(L3ExprFixture.labelledRetryToOuter());
        Object o3 = c3.getMethod("eval", lmx.LmxOccurrence.class)
                .invoke(null, lmx.LmxOccurrence.independent(Integer.valueOf(0)));
        check("labelled RETRY to outer -> n==2", Integer.valueOf(2).equals(o3));

        boolean threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.retryOutsideRegion());
        } catch (IllegalArgumentException e) {
            threw = e.getMessage() != null && e.getMessage().contains("outside region");
        }
        check("RETRY outside region rejected", threw);

        threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.retryWrongLabelIdentity());
        } catch (IllegalArgumentException e) {
            threw = e.getMessage() != null && e.getMessage().contains("not visible");
        }
        check("distinct RETRY_LABEL identity rejected", threw);

        threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.retryUsingLoopLabel());
        } catch (IllegalArgumentException e) {
            threw = e.getMessage() != null && e.getMessage().contains("LOOP_LABEL");
        }
        check("LOOP_LABEL as retry target rejected", threw);

        threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.loopUsingRetryLabel());
        } catch (IllegalArgumentException e) {
            threw = e.getMessage() != null && (
                    e.getMessage().contains("LOOP_LABEL") || e.getMessage().contains("retry"));
        }
        check("RETRY_LABEL as loop target rejected", threw);

        threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.retryDuplicateActiveBinding());
        } catch (IllegalArgumentException e) {
            threw = e.getMessage() != null && e.getMessage().contains("duplicate active retry");
        }
        check("duplicate active retry binding rejected", threw);

        threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.retryInValueContext());
        } catch (IllegalArgumentException e) {
            threw = e.getMessage() != null && e.getMessage().contains("value context");
        }
        check("RETRY in value context rejected", threw);
    }

    private static void testPhysicalLoopLabels() throws Exception {
        Class<?> c1 = loadPrinted(L3ExprFixture.labelledBreakToOuter());
        Object n = c1.getMethod("eval", lmx.LmxOccurrence.class)
                .invoke(null, lmx.LmxOccurrence.independent(Integer.valueOf(0)));
        check("labelled BREAK to outer -> n==1", Integer.valueOf(1).equals(n));

        Class<?> c2 = loadPrinted(L3ExprFixture.labelledContinueOuterOnce());
        Object n2 = c2.getMethod("eval", lmx.LmxOccurrence.class)
                .invoke(null, lmx.LmxOccurrence.independent(Integer.valueOf(0)));
        check("labelled CONTINUE outer -> n==2", Integer.valueOf(2).equals(n2));

        ArgEvalCounter.reset();
        Class<?> c3 = loadPrinted(L3ExprFixture.labelledRedoSkipsConditionProbe());
        Object n3 = c3.getMethod("eval", lmx.LmxOccurrence.class)
                .invoke(null, lmx.LmxOccurrence.independent(Integer.valueOf(0)));
        check("labelled REDO skips cond -> n==2", Integer.valueOf(2).equals(n3));
        check("labelled REDO cond PROBE once", ArgEvalCounter.get() == 1);

        // unlabelled still works (nearest)
        Class<?> c4 = loadPrinted(L3ExprFixture.breakAfterThree());
        Object n4 = c4.getMethod("eval", lmx.LmxOccurrence.class)
                .invoke(null, lmx.LmxOccurrence.independent(Integer.valueOf(0)));
        check("unlabelled BREAK still nearest -> 3", Integer.valueOf(3).equals(n4));

        boolean threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.labelledTransferWrongIdentity());
        } catch (IllegalArgumentException e) {
            threw = e.getMessage() != null && e.getMessage().contains("not visible");
        }
        check("distinct label identity rejected", threw);

        threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.labelledDuplicateActiveBinding());
        } catch (IllegalArgumentException e) {
            threw = e.getMessage() != null && e.getMessage().contains("duplicate active");
        }
        check("duplicate active label binding rejected", threw);

        threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.labelledBreakNonLabelTarget());
        } catch (IllegalArgumentException e) {
            threw = e.getMessage() != null && e.getMessage().contains("LOOP_LABEL");
        }
        check("non-label BREAK target rejected", threw);
    }

    private static void testRedo() throws Exception {
        ArgEvalCounter.reset();
        Class<?> cls = loadPrinted(L3ExprFixture.redoSkipsConditionProbe());
        Object r = cls.getMethod("eval", lmx.LmxOccurrence.class)
                .invoke(null, lmx.LmxOccurrence.independent(Integer.valueOf(0)));
        check("REDO skips cond probe -> n==2", Integer.valueOf(2).equals(r));
        check("REDO cond PROBE ticks once", ArgEvalCounter.get() == 1);

        Class<?> cls2 = loadPrinted(L3ExprFixture.redoThenBodyTailContinues());
        Object flag = cls2.getMethod("eval", lmx.LmxOccurrence.class)
                .invoke(null, lmx.LmxOccurrence.independent(Integer.valueOf(0)));
        check("REDO then body tail sets flag==1", Integer.valueOf(1).equals(flag));

        Class<?> cls3 = loadPrinted(L3ExprFixture.redoNestedNearestOnly());
        Object outer = cls3.getMethod("eval", lmx.LmxOccurrence.class)
                .invoke(null, lmx.LmxOccurrence.independent(Integer.valueOf(0)));
        check("REDO nested nearest -> outer==2", Integer.valueOf(2).equals(outer));

        Class<?> cls4 = loadPrinted(L3ExprFixture.redoInCalleeCallerContinues());
        Object cn = cls4.getMethod("eval", lmx.LmxOccurrence.class)
                .invoke(null, lmx.LmxOccurrence.independent(Integer.valueOf(0)));
        check("REDO in callee isolates caller -> 2", Integer.valueOf(2).equals(cn));

        boolean threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.redoOutsideLoop());
        } catch (IllegalArgumentException e) {
            threw = e.getMessage() != null && e.getMessage().contains("REDO outside loop");
        }
        check("REDO outside loop rejected", threw);

        threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.redoInValueContext());
        } catch (IllegalArgumentException e) {
            threw = e.getMessage() != null && e.getMessage().contains("value context");
        }
        check("REDO in value context rejected", threw);

        threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.redoInFinalSequence());
        } catch (IllegalArgumentException e) {
            threw = true;
        }
        check("REDO final SEQUENCE / malformed rejected", threw);

        threw = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.redoWithChild());
        } catch (IllegalArgumentException e) {
            String m = e.getMessage();
            threw = m != null && (m.contains("REDO arity") || m.contains("LOOP_LABEL"));
        }
        check("REDO with child rejected", threw);
    }

    private static void testOwnershipCycleGuard() throws Exception {
        boolean seqCycle = false;
        boolean so = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.sequenceSelfOwnershipCycle());
        } catch (StackOverflowError e) {
            so = true;
        } catch (IllegalArgumentException e) {
            seqCycle = e.getMessage() != null && e.getMessage().contains("ownership cycle");
            check("SEQUENCE self-cycle message names SEQUENCE", e.getMessage().contains("SEQUENCE"));
        }
        check("SEQUENCE self-cycle rejected (no SO)", seqCycle && !so);

        boolean addCycle = false;
        so = false;
        try {
            L3ClassfilePrinter.emitCallable(L3ExprFixture.addIfOwnershipCycle());
        } catch (StackOverflowError e) {
            so = true;
        } catch (IllegalArgumentException e) {
            addCycle = e.getMessage() != null && e.getMessage().contains("ownership cycle");
        }
        check("ADD/IF structural cycle rejected (no SO)", addCycle && !so);

        Class<?> cls = loadPrinted(L3ExprFixture.sharedAcyclicLiteralAdd());
        Object r = cls.getMethod("eval", lmx.LmxOccurrence.class)
                .invoke(null, lmx.LmxOccurrence.independent(Integer.valueOf(0)));
        check("shared acyclic ADD(x,x) -> 42", Integer.valueOf(42).equals(r));

        // legal recursion still emits/runs (baseline preserved by full suite; spot-check countdown)
        Class<?> cd = loadPrinted(L3ExprFixture.recursiveCountdown());
        Object c0 = cd.getMethod("eval", lmx.LmxOccurrence.class)
                .invoke(null, lmx.LmxOccurrence.independent(Integer.valueOf(0)));
        check("ownership guard preserves recursive countdown 0", Integer.valueOf(0).equals(c0));
    }

    private static void testSealFreezeChildren() throws Exception {
        // Constructor varargs alias cannot mutate node after construction.
        L3Node a = L3Node.ofInt(graph.L3Role.INT_LITERAL, 1);
        L3Node b = L3Node.ofInt(graph.L3Role.INT_LITERAL, 2);
        L3Node[] ctorAlias = new L3Node[] { a, b };
        L3Node seq = new L3Node(graph.L3Role.SEQUENCE, 0, ctorAlias);
        check("ctor childCount 2", seq.childCount() == 2);
        check("ctor child0 physical", seq.child(0) == a);
        check("ctor child1 physical", seq.child(1) == b);
        L3Node c = L3Node.ofInt(graph.L3Role.INT_LITERAL, 3);
        ctorAlias[0] = c;
        ctorAlias[1] = null;
        check("ctor alias mutate does not affect node child0", seq.child(0) == a);
        check("ctor alias mutate does not affect node child1", seq.child(1) == b);
        check("ctor alias mutate leaves childCount", seq.childCount() == 2);

        // children field is private (no public writable array surface).
        boolean publicChildren = false;
        for (Field f : L3Node.class.getFields()) {
            if ("children".equals(f.getName())) {
                publicChildren = true;
            }
        }
        check("no public children field", !publicChildren);
        Field priv = L3Node.class.getDeclaredField("children");
        check("children field is private", Modifier.isPrivate(priv.getModifiers()));

        // Null seal rejected; node stays unsealed with no stuck child; retry succeeds once.
        L3Node shell = L3Node.unsealedCallable();
        check("unsealed shell starts unsealed", !shell.isSealed());
        check("unsealed shell childCount 0", shell.childCount() == 0);
        boolean nullSeal = false;
        try {
            shell.seal(null);
        } catch (IllegalArgumentException e) {
            nullSeal = true;
        }
        check("null seal rejected", nullSeal);
        check("after failed null seal still unsealed", !shell.isSealed());
        check("after failed null seal childCount still 0", shell.childCount() == 0);

        boolean badBody = false;
        try {
            shell.seal(L3ExprFixture.sealFreezeNonReturnBody());
        } catch (IllegalArgumentException e) {
            badBody = true;
        }
        check("non-RETURN seal body rejected", badBody);
        check("after failed malformed seal still unsealed", !shell.isSealed());
        check("after failed malformed seal childCount still 0", shell.childCount() == 0);

        L3Node body = L3ExprFixture.sealFreezeReturn42();
        shell.seal(body);
        check("retry seal after failed null succeeds", shell.isSealed());
        check("sealed childCount 1", shell.childCount() == 1);
        check("sealed child0 physical body", shell.child(0) == body);

        // Seal input is a single node (no caller array alias); double-seal still rejected.
        boolean doubleSeal = false;
        try {
            shell.seal(L3Node.of(graph.L3Role.RETURN, L3Node.ofInt(graph.L3Role.INT_LITERAL, 99)));
        } catch (IllegalStateException e) {
            doubleSeal = true;
        }
        check("seal-freeze double-seal rejected", doubleSeal);
        check("after double-seal attempt body unchanged", shell.child(0) == body);
        check("after double-seal attempt still sealed", shell.isSealed());

        // Physical self-recursion still works through frozen sealed children.
        Class<?> cls = loadPrinted(L3ExprFixture.recursiveCountdown());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Object r = eval.invoke(null, LmxOccurrence.independent(Integer.valueOf(3)));
        check("seal-freeze recursive countdown 3 -> 3", Integer.valueOf(3).equals(r));
        L3Node entry = L3ExprFixture.recursiveCountdown();
        // entry is CALLABLE sealed with RETURN; body IF has CALL to same physical self via child path
        L3Node ret = entry.child(0);
        check("recursive entry sealed RETURN", entry.isSealed() && ret.role == graph.L3Role.RETURN);
    }

    private static boolean hasMethods(Class<?> cls, String... want) {
        Set<String> names = new HashSet<String>();
        for (Method m : cls.getDeclaredMethods()) {
            names.add(m.getName());
        }
        for (String w : want) {
            if (!names.contains(w)) {
                return false;
            }
        }
        return true;
    }

    private static Class<?> loadPrinted(L3Node entry) throws Exception {
        final byte[] bytes = L3ClassfilePrinter.emitCallable(entry);
        ClassLoader parent = ExprSmokeDriver.class.getClassLoader();
        ClassLoader loader = new ClassLoader(parent) {
            @Override
            protected Class<?> loadClass(String name, boolean resolve) throws ClassNotFoundException {
                if ("lmx.gen.PrintedL3Expr".equals(name)) {
                    synchronized (this) {
                        Class<?> c = findLoadedClass(name);
                        if (c == null) {
                            c = defineClass(name, bytes, 0, bytes.length);
                        }
                        if (resolve) {
                            resolveClass(c);
                        }
                        return c;
                    }
                }
                return super.loadClass(name, resolve);
            }
        };
        return loader.loadClass("lmx.gen.PrintedL3Expr");
    }

    private static void check(String name, boolean ok) {
        checks++;
        if (!ok) {
            fails++;
            System.out.println("FAIL " + name);
        }
    }
}
