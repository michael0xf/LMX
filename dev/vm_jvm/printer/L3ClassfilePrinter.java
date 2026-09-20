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
 * Method names {@code c0}..{@code cN}; descriptors fixed from compile-time arity
 * (subject + int args). {@link L3Role#ARG} uses numeric position only.
 * WHILE / recursion deferred.
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

        Map<L3Node, Integer> arity = new IdentityHashMap<L3Node, Integer>();
        for (L3Node c : order) {
            arity.put(c, Integer.valueOf(computeArity(c)));
        }
        validateAll(order, map, arity);

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
            emitOneCallable(cw, order.get(i), i, map, arity);
        }

        // eval alias: subject-only entry convenience (entry arity must be 1)
        int entryArity = arity.get(entry).intValue();
        if (entryArity != 1) {
            throw new IllegalArgumentException("entry callable must have arity 1 for eval alias");
        }
        MethodVisitor alias = cw.visitMethod(
                ACC_PUBLIC | ACC_STATIC, EVAL, "(Llmx/LmxOccurrence;)I", null, null);
        alias.visitCode();
        alias.visitVarInsn(ALOAD, 0);
        alias.visitMethodInsn(INVOKESTATIC, GEN_INTERNAL, "c0", descriptor(1), false);
        alias.visitInsn(IRETURN);
        alias.visitMaxs(0, 0);
        alias.visitEnd();

        cw.visitEnd();
        return cw.toByteArray();
    }

    static String descriptor(int arity) {
        if (arity < 1) {
            throw new IllegalArgumentException("arity");
        }
        StringBuilder sb = new StringBuilder("(Llmx/LmxOccurrence;");
        for (int i = 1; i < arity; i++) {
            sb.append('I');
        }
        sb.append(")I");
        return sb.toString();
    }

    /**
     * Arity = max(1, max ARG index + 1). ARG positions scanned in this callable's body only
     * (CALL callee bodies are not part of this callable's arity).
     */
    static int computeArity(L3Node callable) {
        int[] maxIdx = new int[] {-1};
        scanArity(callable.children[0], maxIdx);
        if (maxIdx[0] < 0) {
            return 1;
        }
        return maxIdx[0] + 1;
    }

    private static void scanArity(L3Node n, int[] maxIdx) {
        if (n == null) {
            return;
        }
        if (n.role == L3Role.ARG) {
            if (n.intPayload > maxIdx[0]) {
                maxIdx[0] = n.intPayload;
            }
            return;
        }
        if (n.role == L3Role.CALL) {
            // do not enter callee; scan argument expressions only
            for (int i = 1; i < n.children.length; i++) {
                scanArity(n.children[i], maxIdx);
            }
            return;
        }
        for (L3Node c : n.children) {
            scanArity(c, maxIdx);
        }
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

    private static void validateAll(
            List<L3Node> order, Map<L3Node, Integer> map, Map<L3Node, Integer> arity) {
        for (L3Node c : order) {
            if (c.children.length != 1 || c.children[0].role != L3Role.RETURN) {
                throw new IllegalArgumentException("CALLABLE body must be a single RETURN");
            }
            validateIntExpr(c.children[0].children[0], map, arity, c, arity.get(c).intValue());
        }
    }

    private static void validateIntExpr(
            L3Node expr,
            Map<L3Node, Integer> map,
            Map<L3Node, Integer> arity,
            L3Node currentCallable,
            int currentArity) {
        L3Role r = expr.role;
        if (r == L3Role.INT_LITERAL) {
            return;
        }
        if (r == L3Role.PROBE) {
            return;
        }
        if (r == L3Role.ARG) {
            int idx = expr.intPayload;
            if (idx < 1) {
                throw new IllegalArgumentException("ARG out of range for int context (need >= 1)");
            }
            if (idx >= currentArity) {
                throw new IllegalArgumentException("ARG out of range");
            }
            return;
        }
        if (r == L3Role.FIELD_FOLLOW) {
            if (expr.children.length != 1) {
                throw new IllegalArgumentException("FIELD_FOLLOW arity");
            }
            validateOccurrence(expr.children[0], currentArity);
            return;
        }
        if (r == L3Role.ADD) {
            if (expr.children.length != 2) {
                throw new IllegalArgumentException("ADD arity");
            }
            validateIntExpr(expr.children[0], map, arity, currentCallable, currentArity);
            validateIntExpr(expr.children[1], map, arity, currentCallable, currentArity);
            return;
        }
        if (r == L3Role.CALL) {
            if (expr.children.length < 2) {
                throw new IllegalArgumentException("CALL arity: need callee + subject arg");
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
            int need = arity.get(callee).intValue();
            int got = expr.children.length - 1;
            if (got != need) {
                throw new IllegalArgumentException(
                        "CALL arg count mismatch: need " + need + " got " + got);
            }
            validateOccurrence(expr.children[1], currentArity);
            for (int i = 2; i < expr.children.length; i++) {
                validateIntExpr(expr.children[i], map, arity, currentCallable, currentArity);
            }
            return;
        }
        if (r == L3Role.IF) {
            if (expr.children.length != 3) {
                throw new IllegalArgumentException("IF arity: need condition, then, else");
            }
            validateIntExpr(expr.children[0], map, arity, currentCallable, currentArity);
            validateIntExpr(expr.children[1], map, arity, currentCallable, currentArity);
            validateIntExpr(expr.children[2], map, arity, currentCallable, currentArity);
            return;
        }
        if (r == L3Role.SUBJECT_REF) {
            throw new IllegalArgumentException(
                    "unsupported condition/value type: SUBJECT_REF is not an int expression");
        }
        if (r == L3Role.UNSUPPORTED) {
            throw new IllegalArgumentException("unsupported role");
        }
        throw new IllegalArgumentException("unsupported role");
    }

    private static void validateOccurrence(L3Node n, int currentArity) {
        if (n.role == L3Role.SUBJECT_REF) {
            return;
        }
        if (n.role == L3Role.ARG) {
            if (n.intPayload != 0) {
                throw new IllegalArgumentException("occurrence ARG must be position 0 (subject)");
            }
            if (currentArity < 1) {
                throw new IllegalArgumentException("ARG out of range");
            }
            return;
        }
        throw new IllegalArgumentException("occurrence base must be SUBJECT_REF or ARG(0)");
    }

    private static void emitOneCallable(
            ClassWriter cw,
            L3Node callable,
            int index,
            Map<L3Node, Integer> map,
            Map<L3Node, Integer> arity) {
        int ar = arity.get(callable).intValue();
        String name = "c" + index;
        String desc = descriptor(ar);
        MethodVisitor mv = cw.visitMethod(ACC_PUBLIC | ACC_STATIC, name, desc, null, null);
        mv.visitCode();
        L3Node ret = callable.children[0];
        emitIntExpr(mv, ret.children[0], map, arity);
        mv.visitInsn(IRETURN);
        mv.visitMaxs(0, 0);
        mv.visitEnd();
    }

    private static void emitIntExpr(
            MethodVisitor mv,
            L3Node expr,
            Map<L3Node, Integer> map,
            Map<L3Node, Integer> arity) {
        L3Role r = expr.role;
        if (r == L3Role.INT_LITERAL) {
            mv.visitLdcInsn(Integer.valueOf(expr.intPayload));
        } else if (r == L3Role.PROBE) {
            mv.visitMethodInsn(INVOKESTATIC, "graph/ArgEvalCounter", "tick", "()I", false);
        } else if (r == L3Role.ARG) {
            mv.visitVarInsn(ILOAD, expr.intPayload);
        } else if (r == L3Role.FIELD_FOLLOW) {
            emitOccurrence(mv, expr.children[0]);
            mv.visitLdcInsn(Integer.valueOf(expr.intPayload));
            mv.visitMethodInsn(INVOKEVIRTUAL, "lmx/LmxOccurrence", "child", "(I)Ljava/lang/Object;", false);
            mv.visitTypeInsn(CHECKCAST, "java/lang/Integer");
            mv.visitMethodInsn(INVOKEVIRTUAL, "java/lang/Integer", "intValue", "()I", false);
        } else if (r == L3Role.ADD) {
            emitIntExpr(mv, expr.children[0], map, arity);
            emitIntExpr(mv, expr.children[1], map, arity);
            mv.visitInsn(IADD);
        } else if (r == L3Role.CALL) {
            // evaluate args left-to-right once, then invoke
            emitOccurrence(mv, expr.children[1]);
            for (int i = 2; i < expr.children.length; i++) {
                emitIntExpr(mv, expr.children[i], map, arity);
            }
            L3Node callee = expr.children[0];
            int calleeIndex = map.get(callee).intValue();
            int calleeArity = arity.get(callee).intValue();
            mv.visitMethodInsn(
                    INVOKESTATIC,
                    GEN_INTERNAL,
                    "c" + calleeIndex,
                    descriptor(calleeArity),
                    false);
        } else if (r == L3Role.IF) {
            Label elseL = new Label();
            Label endL = new Label();
            emitIntExpr(mv, expr.children[0], map, arity);
            mv.visitJumpInsn(IFEQ, elseL);
            emitIntExpr(mv, expr.children[1], map, arity);
            mv.visitJumpInsn(GOTO, endL);
            mv.visitLabel(elseL);
            emitIntExpr(mv, expr.children[2], map, arity);
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
        } else if (expr.role == L3Role.ARG && expr.intPayload == 0) {
            mv.visitVarInsn(ALOAD, 0);
        } else {
            throw new IllegalArgumentException("occurrence base must be SUBJECT_REF or ARG(0)");
        }
    }

    public static List<String> plannedMethodNames(L3Node entry) {
        List<L3Node> order = new ArrayList<L3Node>();
        Map<L3Node, Integer> map = new IdentityHashMap<L3Node, Integer>();
        collectCallables(entry, order, map);
        Map<L3Node, Integer> arity = new IdentityHashMap<L3Node, Integer>();
        for (L3Node c : order) {
            arity.put(c, Integer.valueOf(computeArity(c)));
        }
        validateAll(order, map, arity);
        List<String> names = new ArrayList<String>();
        for (int i = 0; i < order.size(); i++) {
            names.add("c" + i);
        }
        names.add(EVAL);
        return names;
    }
}
