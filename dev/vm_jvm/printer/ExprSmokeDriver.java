package printer;

import graph.L3ExprFixture;
import graph.L3Node;
import lmx.LmxOccurrence;
import java.lang.reflect.Method;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
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
        // true path: subject[0]=1 Integer, subject[1]=String ? else FIELD_FOLLOW(1) would fail
        Class<?> t = loadPrinted(L3ExprFixture.ifTrueUntakenElseInvalid());
        Method evalT = t.getMethod("eval", LmxOccurrence.class);
        LmxOccurrence subT = LmxOccurrence.independent(Integer.valueOf(1), "boom");
        Object rt = evalT.invoke(null, subT);
        check("IF true untaken else not evaluated ? 42", Integer.valueOf(42).equals(rt));

        // false path: subject[0]=0, subject[1]=String ? then would fail if evaluated
        Class<?> f = loadPrinted(L3ExprFixture.ifFalseUntakenThenInvalid());
        Method evalF = f.getMethod("eval", LmxOccurrence.class);
        LmxOccurrence subF = LmxOccurrence.independent(Integer.valueOf(0), "boom");
        Object rf = evalF.invoke(null, subF);
        check("IF false untaken then not evaluated ? 7", Integer.valueOf(7).equals(rf));
    }

    private static void testIfNestedCall() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.ifNestedCallThen());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        LmxOccurrence subject = LmxOccurrence.independent(Integer.valueOf(3));
        Object r = eval.invoke(null, subject);
        check("IF selects nested CALL ? 3", Integer.valueOf(3).equals(r));
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
        // Do not put generated bytes on the app classpath: parent would cache the first
        // PrintedL3Expr and later fixtures would silently reuse it.
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
