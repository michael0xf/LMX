package printer;

import graph.L3Node;
import graph.L3Role;
import java.util.ArrayList;
import java.util.IdentityHashMap;
import java.util.List;
import java.util.Map;
import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.Label;
import org.objectweb.asm.MethodVisitor;
import org.objectweb.asm.Opcodes;

/**
 * Emits one JVM method per reachable {@link L3Role#CALLABLE}.
 * Method names are {@code c0}..{@code cN} from a deterministic traversal map (numeric only).
 * {@link L3Role#CALL} follows the callee by physical child reference, not text.
 * {@link L3Role#IF} emits branch bytecode (int condition: zero=false). WHILE deferred.
 * Recursion is deferred.
 */
public final class L3ClassfilePrinter implements Opcodes {
    public static final String GEN_INTERNAL = "lmx/gen/PrintedL3Expr";
    public static final String EVAL = "eval";

    private L3ClassfilePrinter() {}

    public static byte[] emitCallable(L3Node entry) {
        if (entry == null || entry.role != L3Role.CALLABLE) {
            throw new IllegalArgumentException("expected CALLABLE root");
        }
        List<L3Node> order = new ArrayList<L3Node>();
        Map<L3Node, Integer> map = new IdentityHashMap<L3Node, Integer>();
        collectCallables(entry, order, map);
        validateAll(order, map);

        ClassWriter cw = new ClassWriter(ClassWriter.COMPUTE_FRAMES | ClassWriter.COMPUTE_MAXS);
        cw.visit(V11, ACC_PUBLIC | ACC_FINAL, GEN_INTERNAL, null, "java/lang/Object", null);

        MethodVisitor init = cw.visitMethod(ACC_PUBLIC, "<init>", "()V", null, null);
        init.visitCode();
        init.visitVarInsn(ALOAD, 0);
        init.visitMethodInsn(INVOKESPECIAL, "java/lang/Object", "<init>", "()V", false);
        init.visitInsn(RETURN);
        init.visitMaxs(0, 0);
        init.visitEnd();

        for (int i = 0; i < order.size(); i++) {
            emitOneCallable(cw, order.get(i), i, map);
        }
        MethodVisitor alias = cw.visitMethod(
                ACC_PUBLIC | ACC_STATIC, EVAL, "(Llmx/LmxOccurrence;)I", null, null);
        alias.visitCode();
        alias.visitVarInsn(ALOAD, 0);
        alias.visitMethodInsn(INVOKESTATIC, GEN_INTERNAL, "c0", "(Llmx/LmxOccurrence;)I", false);
        alias.visitInsn(IRETURN);
        alias.visitMaxs(0, 0);
        alias.visitEnd();

        cw.visitEnd();
        return cw.toByteArray();
    }

    private static void collectCallables(L3Node entry, List<L3Node> order, Map<L3Node, Integer> map) {
        walk(entry, order, map);
    }

    private static void walk(L3Node n, List<L3Node> order, Map<L3Node, Integer> map) {
        if (n == null) {
            return;
        }
        if (n.role == L3Role.CALLABLE) {
            if (!map.containsKey(n)) {
                map.put(n, Integer.valueOf(order.size()));
                order.add(n);
            }
        }
        if (n.role == L3Role.CALL) {
            if (n.children.length < 1) {
                throw new IllegalArgumentException("CALL needs callee child");
            }
            L3Node callee = n.children[0];
            if (callee.role != L3Role.CALLABLE) {
                throw new IllegalArgumentException("CALL callee must be CALLABLE node");
            }
            walk(callee, order, map);
            for (int i = 1; i < n.children.length; i++) {
                walk(n.children[i], order, map);
            }
            return;
        }
        for (L3Node c : n.children) {
            walk(c, order, map);
        }
    }

    private static void validateAll(List<L3Node> order, Map<L3Node, Integer> map) {
        for (L3Node c : order) {
            if (c.children.length != 1 || c.children[0].role != L3Role.RETURN) {
                throw new IllegalArgumentException("CALLABLE body must be a single RETURN");
            }
            validateIntExpr(c.children[0].children[0], map, c);
        }
    }

    /** Int-producing expression for the current int-only slice. */
    private static void validateIntExpr(L3Node expr, Map<L3Node, Integer> map, L3Node currentCallable) {
        L3Role r = expr.role;
        if (r == L3Role.INT_LITERAL) {
            return;
        }
        if (r == L3Role.FIELD_FOLLOW) {
            if (expr.children.length != 1) {
                throw new IllegalArgumentException("FIELD_FOLLOW arity");
            }
            validateOccurrence(expr.children[0]);
            return;
        }
        if (r == L3Role.ADD) {
            if (expr.children.length != 2) {
                throw new IllegalArgumentException("ADD arity");
            }
            validateIntExpr(expr.children[0], map, currentCallable);
            validateIntExpr(expr.children[1], map, currentCallable);
            return;
        }
        if (r == L3Role.CALL) {
            if (expr.children.length != 2) {
                throw new IllegalArgumentException("CALL arity: need callee + one subject arg");
            }
            L3Node callee = expr.children[0];
            if (callee.role != L3Role.CALLABLE) {
                throw new IllegalArgumentException("CALL callee must be CALLABLE");
            }
            if (callee == currentCallable) {
                throw new IllegalArgumentException("recursion deferred");
            }
            if (!map.containsKey(callee)) {
                throw new IllegalArgumentException("CALL callee not reachable/mapped");
            }
            validateOccurrence(expr.children[1]);
            return;
        }
        if (r == L3Role.IF) {
            if (expr.children.length != 3) {
                throw new IllegalArgumentException("IF arity: need condition, then, else");
            }
            validateIntExpr(expr.children[0], map, currentCallable);
            validateIntExpr(expr.children[1], map, currentCallable);
            validateIntExpr(expr.children[2], map, currentCallable);
            return;
        }
        if (r == L3Role.SUBJECT_REF) {
            throw new IllegalArgumentException("unsupported condition/value type: SUBJECT_REF is not an int expression");
        }
        if (r == L3Role.UNSUPPORTED) {
            throw new IllegalArgumentException("unsupported role");
        }
        throw new IllegalArgumentException("unsupported role");
    }

    private static void validateOccurrence(L3Node n) {
        if (n.role != L3Role.SUBJECT_REF) {
            throw new IllegalArgumentException("occurrence base must be SUBJECT_REF");
        }
    }

    private static void emitOneCallable(
            ClassWriter cw, L3Node callable, int index, Map<L3Node, Integer> map) {
        String name = "c" + index;
        MethodVisitor mv = cw.visitMethod(
                ACC_PUBLIC | ACC_STATIC, name, "(Llmx/LmxOccurrence;)I", null, null);
        mv.visitCode();
        L3Node ret = callable.children[0];
        emitIntExpr(mv, ret.children[0], map);
        mv.visitInsn(IRETURN);
        mv.visitMaxs(0, 0);
        mv.visitEnd();
    }

    private static void emitIntExpr(MethodVisitor mv, L3Node expr, Map<L3Node, Integer> map) {
        L3Role r = expr.role;
        if (r == L3Role.INT_LITERAL) {
            mv.visitLdcInsn(Integer.valueOf(expr.intPayload));
        } else if (r == L3Role.FIELD_FOLLOW) {
            emitOccurrence(mv, expr.children[0]);
            mv.visitLdcInsn(Integer.valueOf(expr.intPayload));
            mv.visitMethodInsn(INVOKEVIRTUAL, "lmx/LmxOccurrence", "child", "(I)Ljava/lang/Object;", false);
            mv.visitTypeInsn(CHECKCAST, "java/lang/Integer");
            mv.visitMethodInsn(INVOKEVIRTUAL, "java/lang/Integer", "intValue", "()I", false);
        } else if (r == L3Role.ADD) {
            emitIntExpr(mv, expr.children[0], map);
            emitIntExpr(mv, expr.children[1], map);
            mv.visitInsn(IADD);
        } else if (r == L3Role.CALL) {
            emitOccurrence(mv, expr.children[1]);
            int calleeIndex = map.get(expr.children[0]).intValue();
            String calleeName = "c" + calleeIndex;
            mv.visitMethodInsn(
                    INVOKESTATIC, GEN_INTERNAL, calleeName, "(Llmx/LmxOccurrence;)I", false);
        } else if (r == L3Role.IF) {
            Label elseL = new Label();
            Label endL = new Label();
            emitIntExpr(mv, expr.children[0], map);
            mv.visitJumpInsn(IFEQ, elseL);
            emitIntExpr(mv, expr.children[1], map);
            mv.visitJumpInsn(GOTO, endL);
            mv.visitLabel(elseL);
            emitIntExpr(mv, expr.children[2], map);
            mv.visitLabel(endL);
        } else if (r == L3Role.SUBJECT_REF) {
            throw new IllegalArgumentException("SUBJECT_REF is not an int expression");
        } else {
            throw new IllegalArgumentException("unsupported role");
        }
    }

    private static void emitOccurrence(MethodVisitor mv, L3Node expr) {
        if (expr.role == L3Role.SUBJECT_REF) {
            mv.visitVarInsn(ALOAD, 0);
        } else {
            throw new IllegalArgumentException("occurrence base must be SUBJECT_REF");
        }
    }

    public static List<String> plannedMethodNames(L3Node entry) {
        List<L3Node> order = new ArrayList<L3Node>();
        Map<L3Node, Integer> map = new IdentityHashMap<L3Node, Integer>();
        collectCallables(entry, order, map);
        validateAll(order, map);
        List<String> names = new ArrayList<String>();
        for (int i = 0; i < order.size(); i++) {
            names.add("c" + i);
        }
        names.add(EVAL);
        return names;
    }
}
