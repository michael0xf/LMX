package printer;

import graph.L3SmokeFixture;
import java.lang.reflect.Method;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public final class PrinterDriver {
    public static void main(String[] args) throws Exception {
        byte[] cls = L3ClassfilePrinter.emit(L3SmokeFixture.program());
        Path outDir = Paths.get("dev/vm_jvm/out/lmx/gen");
        Files.createDirectories(outDir);
        Path classFile = outDir.resolve("PrintedL3Smoke.class");
        Files.write(classFile, cls);
        System.out.println("WROTE " + classFile.toAbsolutePath().normalize() + " bytes=" + cls.length);

        ClassLoader parent = PrinterDriver.class.getClassLoader();
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
        Class<?> loaded = loader.loadClass("lmx.gen.PrintedL3Smoke");
        Method main = loaded.getMethod("main", String[].class);
        main.invoke(null, (Object) new String[0]);
    }
}
