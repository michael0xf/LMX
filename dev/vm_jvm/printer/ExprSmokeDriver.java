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
        // leaf returns subject[0]=10; caller returns 10+5=15
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
        // orphan exists as object but was never linked ? still only 2 callables emitted
        check("orphan is CALLABLE but unreachable", g.orphan.role == graph.L3Role.CALLABLE && g.orphan != g.entry);
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
        byte[] bytes = L3ClassfilePrinter.emitCallable(entry);
        Path outDir = Paths.get("dev/vm_jvm/out/lmx/gen");
        Files.createDirectories(outDir);
        Path classFile = outDir.resolve("PrintedL3Expr.class");
        Files.write(classFile, bytes);
        ClassLoader parent = ExprSmokeDriver.class.getClassLoader();
        ClassLoader loader = new ClassLoader(parent) {
            @Override
            protected Class<?> findClass(String name) throws ClassNotFoundException {
                try {
                    Path p = Paths.get("dev/vm_jvm/out").resolve(name.replace('.', '/') + ".class");
                    byte[] b = Files.readAllBytes(p);
                    return defineClass(name, b, 0, b.length);
                } catch (Exception e) {
                    throw new ClassNotFoundException(name, e);
                }
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
