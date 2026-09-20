package printer;

import graph.L3ExprFixture;
import graph.L3Node;
import lmx.LmxOccurrence;
import java.lang.reflect.Method;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Print callable from L3 expression graph, load, invoke; assert semantics.
 */
public final class ExprSmokeDriver {
    private static int checks;
    private static int fails;

    public static void main(String[] args) throws Exception {
        checks = 0;
        fails = 0;

        testUnsupportedRejected();
        testEvalAddFieldFollow();
        testSubjectIdentityNoCopy();

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
        check("unsupported role rejected at print", threw);
    }

    private static void testEvalAddFieldFollow() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.callableAddField0Plus5());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        LmxOccurrence subject = LmxOccurrence.independent(Integer.valueOf(10));
        Object result = eval.invoke(null, subject);
        check("add+return 10+5=15", Integer.valueOf(15).equals(result));
        check("field-follow used subject[0]", Integer.valueOf(10).equals(subject.child(0)));
    }

    private static void testSubjectIdentityNoCopy() throws Exception {
        Class<?> cls = loadPrinted(L3ExprFixture.callableAddField0Plus5());
        Method eval = cls.getMethod("eval", LmxOccurrence.class);
        Integer cell = Integer.valueOf(7);
        LmxOccurrence subject = LmxOccurrence.independent(cell);
        eval.invoke(null, subject);
        check("subject identity retained", subject.child(0) == cell);
        check("subject node still independent", subject.node() == null);
        // second eval same subject ? same result path without replacing graph
        Object r2 = eval.invoke(null, subject);
        check("second eval 7+5=12", Integer.valueOf(12).equals(r2));
        check("still same cell after second eval", subject.child(0) == cell);
    }

    private static Class<?> loadPrinted(L3Node callable) throws Exception {
        byte[] bytes = L3ClassfilePrinter.emitCallable(callable);
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
