package printer;

import graph.L3Node;
import graph.L3Role;
import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.MethodVisitor;
import org.objectweb.asm.Opcodes;

/**
 * Emits a JVM callable from an L3 expression graph.
 * Role dispatch is physical identity only ({@code ==} on {@link L3Role}).
 * Produced method: {@code public static int eval(lmx.LmxOccurrence subject)}.
 */
public final class L3ClassfilePrinter implements Opcodes {
    public static final String GEN_INTERNAL = "lmx/gen/PrintedL3Expr";

    private L3ClassfilePrinter() {}

    public static byte[] emitCallable(L3Node callable) {
        if (callable == null || callable.role != L3Role.CALLABLE) {
            throw new IllegalArgumentException("expected CALLABLE root");
        }
        if (callable.children.length != 1 || callable.children[0].role != L3Role.RETURN) {
            throw new IllegalArgumentException("CALLABLE body must be a single RETURN");
        }
        L3Node ret = callable.children[0];
        if (ret.children.length != 1) {
            throw new IllegalArgumentException("RETURN needs one expression");
        }

        ClassWriter cw = new ClassWriter(ClassWriter.COMPUTE_FRAMES | ClassWriter.COMPUTE_MAXS);
        cw.visit(V11, ACC_PUBLIC | ACC_FINAL, GEN_INTERNAL, null, "java/lang/Object", null);

        MethodVisitor init = cw.visitMethod(ACC_PUBLIC, "<init>", "()V", null, null);
        init.visitCode();
        init.visitVarInsn(ALOAD, 0);
        init.visitMethodInsn(INVOKESPECIAL, "java/lang/Object", "<init>", "()V", false);
        init.visitInsn(RETURN);
        init.visitMaxs(0, 0);
        init.visitEnd();

        MethodVisitor mv = cw.visitMethod(
                ACC_PUBLIC | ACC_STATIC,
                "eval",
                "(Llmx/LmxOccurrence;)I",
                null,
                null);
        mv.visitCode();
        emitExpr(mv, ret.children[0]);
        mv.visitInsn(IRETURN);
        mv.visitMaxs(0, 0);
        mv.visitEnd();

        cw.visitEnd();
        return cw.toByteArray();
    }

    /** Leaves an int on the operand stack. */
    private static void emitExpr(MethodVisitor mv, L3Node expr) {
        L3Role r = expr.role;
        if (r == L3Role.SUBJECT_REF) {
            mv.visitVarInsn(ALOAD, 0);
            // subject is LmxOccurrence ? not an int; only valid under FIELD_FOLLOW/etc.
            // For typed int context, SUBJECT_REF alone is invalid unless wrapped.
            throw new IllegalArgumentException("SUBJECT_REF is not an int expression alone");
        } else if (r == L3Role.INT_LITERAL) {
            mv.visitLdcInsn(Integer.valueOf(expr.intPayload));
        } else if (r == L3Role.FIELD_FOLLOW) {
            if (expr.children.length != 1) {
                throw new IllegalArgumentException("FIELD_FOLLOW needs one base");
            }
            emitOccurrence(mv, expr.children[0]);
            mv.visitLdcInsn(Integer.valueOf(expr.intPayload));
            mv.visitMethodInsn(INVOKEVIRTUAL, "lmx/LmxOccurrence", "child", "(I)Ljava/lang/Object;", false);
            mv.visitTypeInsn(CHECKCAST, "java/lang/Integer");
            mv.visitMethodInsn(INVOKEVIRTUAL, "java/lang/Integer", "intValue", "()I", false);
        } else if (r == L3Role.ADD) {
            if (expr.children.length != 2) {
                throw new IllegalArgumentException("ADD needs two ints");
            }
            emitExpr(mv, expr.children[0]);
            emitExpr(mv, expr.children[1]);
            mv.visitInsn(IADD);
        } else if (r == L3Role.RETURN || r == L3Role.CALLABLE) {
            throw new IllegalArgumentException("RETURN/CALLABLE not an expression");
        } else if (r == L3Role.UNSUPPORTED) {
            throw new IllegalArgumentException("unsupported role");
        } else {
            throw new IllegalArgumentException("unsupported role");
        }
    }

    /** Leaves an LmxOccurrence reference on the stack (no copy). */
    private static void emitOccurrence(MethodVisitor mv, L3Node expr) {
        if (expr.role == L3Role.SUBJECT_REF) {
            mv.visitVarInsn(ALOAD, 0);
        } else {
            throw new IllegalArgumentException("occurrence base must be SUBJECT_REF in this slice");
        }
    }
}
