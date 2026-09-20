package printer;

import graph.L3Node;
import graph.L3Role;
import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.Label;
import org.objectweb.asm.MethodVisitor;
import org.objectweb.asm.Opcodes;

/**
 * L3 graph ? classfile. Role dispatch by physical identity only.
 * Emitted class uses {@link lmx.LmxOccurrence}.
 */
public final class L3ClassfilePrinter implements Opcodes {
    public static final String GEN_INTERNAL = "lmx/gen/PrintedL3Smoke";

    private L3ClassfilePrinter() {}

    public static byte[] emit(L3Node program) {
        if (program == null || program.role != L3Role.PROGRAM) {
            throw new IllegalArgumentException("expected PROGRAM root");
        }
        ClassWriter cw = new ClassWriter(ClassWriter.COMPUTE_FRAMES | ClassWriter.COMPUTE_MAXS);
        cw.visit(V11, ACC_PUBLIC | ACC_FINAL, GEN_INTERNAL, null, "java/lang/Object", null);

        cw.visitField(ACC_PRIVATE | ACC_STATIC, "checks", "I", null, null).visitEnd();
        cw.visitField(ACC_PRIVATE | ACC_STATIC, "fails", "I", null, null).visitEnd();

        MethodVisitor init = cw.visitMethod(ACC_PUBLIC, "<init>", "()V", null, null);
        init.visitCode();
        init.visitVarInsn(ALOAD, 0);
        init.visitMethodInsn(INVOKESPECIAL, "java/lang/Object", "<init>", "()V", false);
        init.visitInsn(RETURN);
        init.visitMaxs(0, 0);
        init.visitEnd();

        emitCheck(cw);
        emitBoundsOk(cw);
        emitFieldFollowOk(cw);
        emitMergeOk(cw);
        emitNestedOk(cw);

        MethodVisitor mv = cw.visitMethod(ACC_PUBLIC | ACC_STATIC, "main", "([Ljava/lang/String;)V", null, null);
        mv.visitCode();
        mv.visitInsn(ICONST_0);
        mv.visitFieldInsn(PUTSTATIC, GEN_INTERNAL, "checks", "I");
        mv.visitInsn(ICONST_0);
        mv.visitFieldInsn(PUTSTATIC, GEN_INTERNAL, "fails", "I");

        for (L3Node step : program.children) {
            emitStep(mv, step);
        }

        Label ok = new Label();
        mv.visitFieldInsn(GETSTATIC, GEN_INTERNAL, "fails", "I");
        mv.visitJumpInsn(IFEQ, ok);
        mv.visitFieldInsn(GETSTATIC, "java/lang/System", "out", "Ljava/io/PrintStream;");
        mv.visitTypeInsn(NEW, "java/lang/StringBuilder");
        mv.visitInsn(DUP);
        mv.visitMethodInsn(INVOKESPECIAL, "java/lang/StringBuilder", "<init>", "()V", false);
        mv.visitLdcInsn("FAIL PrintedL3Smoke checks=");
        mv.visitMethodInsn(INVOKEVIRTUAL, "java/lang/StringBuilder", "append", "(Ljava/lang/String;)Ljava/lang/StringBuilder;", false);
        mv.visitFieldInsn(GETSTATIC, GEN_INTERNAL, "checks", "I");
        mv.visitMethodInsn(INVOKEVIRTUAL, "java/lang/StringBuilder", "append", "(I)Ljava/lang/StringBuilder;", false);
        mv.visitLdcInsn(" failures=");
        mv.visitMethodInsn(INVOKEVIRTUAL, "java/lang/StringBuilder", "append", "(Ljava/lang/String;)Ljava/lang/StringBuilder;", false);
        mv.visitFieldInsn(GETSTATIC, GEN_INTERNAL, "fails", "I");
        mv.visitMethodInsn(INVOKEVIRTUAL, "java/lang/StringBuilder", "append", "(I)Ljava/lang/StringBuilder;", false);
        mv.visitMethodInsn(INVOKEVIRTUAL, "java/lang/StringBuilder", "toString", "()Ljava/lang/String;", false);
        mv.visitMethodInsn(INVOKEVIRTUAL, "java/io/PrintStream", "println", "(Ljava/lang/String;)V", false);
        mv.visitInsn(ICONST_1);
        mv.visitMethodInsn(INVOKESTATIC, "java/lang/System", "exit", "(I)V", false);

        mv.visitLabel(ok);
        mv.visitFieldInsn(GETSTATIC, "java/lang/System", "out", "Ljava/io/PrintStream;");
        mv.visitTypeInsn(NEW, "java/lang/StringBuilder");
        mv.visitInsn(DUP);
        mv.visitMethodInsn(INVOKESPECIAL, "java/lang/StringBuilder", "<init>", "()V", false);
        mv.visitLdcInsn("PASS PrintedL3Smoke checks=");
        mv.visitMethodInsn(INVOKEVIRTUAL, "java/lang/StringBuilder", "append", "(Ljava/lang/String;)Ljava/lang/StringBuilder;", false);
        mv.visitFieldInsn(GETSTATIC, GEN_INTERNAL, "checks", "I");
        mv.visitMethodInsn(INVOKEVIRTUAL, "java/lang/StringBuilder", "append", "(I)Ljava/lang/StringBuilder;", false);
        mv.visitLdcInsn(" failures=0");
        mv.visitMethodInsn(INVOKEVIRTUAL, "java/lang/StringBuilder", "append", "(Ljava/lang/String;)Ljava/lang/StringBuilder;", false);
        mv.visitMethodInsn(INVOKEVIRTUAL, "java/lang/StringBuilder", "toString", "()Ljava/lang/String;", false);
        mv.visitMethodInsn(INVOKEVIRTUAL, "java/io/PrintStream", "println", "(Ljava/lang/String;)V", false);
        mv.visitInsn(RETURN);
        mv.visitMaxs(0, 0);
        mv.visitEnd();

        cw.visitEnd();
        return cw.toByteArray();
    }

    private static void emitStep(MethodVisitor mv, L3Node step) {
        L3Role r = step.role;
        if (r == L3Role.CHECK_INT) {
            mv.visitLdcInsn(Integer.valueOf(step.intPayload));
            mv.visitLdcInsn(Integer.valueOf(42));
            Label good = new Label();
            mv.visitJumpInsn(IF_ICMPEQ, good);
            mv.visitInsn(ICONST_0);
            Label done = new Label();
            mv.visitJumpInsn(GOTO, done);
            mv.visitLabel(good);
            mv.visitInsn(ICONST_1);
            mv.visitLabel(done);
            mv.visitMethodInsn(INVOKESTATIC, GEN_INTERNAL, "check", "(Z)V", false);
        } else if (r == L3Role.CHECK_VOID_STEP) {
            mv.visitInsn(ICONST_1);
            mv.visitMethodInsn(INVOKESTATIC, GEN_INTERNAL, "check", "(Z)V", false);
        } else if (r == L3Role.CHECK_INDEPENDENT) {
            mv.visitInsn(ICONST_1);
            mv.visitTypeInsn(ANEWARRAY, "java/lang/Object");
            mv.visitInsn(DUP);
            mv.visitInsn(ICONST_0);
            mv.visitLdcInsn("leaf");
            mv.visitInsn(AASTORE);
            mv.visitMethodInsn(INVOKESTATIC, "lmx/LmxOccurrence", "independent", "([Ljava/lang/Object;)Llmx/LmxOccurrence;", false);
            mv.visitMethodInsn(INVOKEVIRTUAL, "lmx/LmxOccurrence", "node", "()Llmx/LmxOccurrence;", false);
            Label good = new Label();
            mv.visitJumpInsn(IFNULL, good);
            mv.visitInsn(ICONST_0);
            Label done = new Label();
            mv.visitJumpInsn(GOTO, done);
            mv.visitLabel(good);
            mv.visitInsn(ICONST_1);
            mv.visitLabel(done);
            mv.visitMethodInsn(INVOKESTATIC, GEN_INTERNAL, "check", "(Z)V", false);
        } else if (r == L3Role.CHECK_NESTED) {
            mv.visitMethodInsn(INVOKESTATIC, GEN_INTERNAL, "nestedOk", "()Z", false);
            mv.visitMethodInsn(INVOKESTATIC, GEN_INTERNAL, "check", "(Z)V", false);
        } else if (r == L3Role.CHECK_BOUNDS) {
            mv.visitMethodInsn(INVOKESTATIC, GEN_INTERNAL, "boundsOk", "()Z", false);
            mv.visitMethodInsn(INVOKESTATIC, GEN_INTERNAL, "check", "(Z)V", false);
        } else if (r == L3Role.CHECK_FIELD_FOLLOW) {
            mv.visitMethodInsn(INVOKESTATIC, GEN_INTERNAL, "fieldFollowOk", "()Z", false);
            mv.visitMethodInsn(INVOKESTATIC, GEN_INTERNAL, "check", "(Z)V", false);
        } else if (r == L3Role.CHECK_MERGE) {
            mv.visitMethodInsn(INVOKESTATIC, GEN_INTERNAL, "mergeOk", "()Z", false);
            mv.visitMethodInsn(INVOKESTATIC, GEN_INTERNAL, "check", "(Z)V", false);
        } else {
            throw new IllegalArgumentException("unsupported role in first printer slice");
        }
    }

    private static void emitCheck(ClassWriter cw) {
        MethodVisitor mv = cw.visitMethod(ACC_PRIVATE | ACC_STATIC, "check", "(Z)V", null, null);
        mv.visitCode();
        mv.visitFieldInsn(GETSTATIC, GEN_INTERNAL, "checks", "I");
        mv.visitInsn(ICONST_1);
        mv.visitInsn(IADD);
        mv.visitFieldInsn(PUTSTATIC, GEN_INTERNAL, "checks", "I");
        Label ok = new Label();
        mv.visitVarInsn(ILOAD, 0);
        mv.visitJumpInsn(IFNE, ok);
        mv.visitFieldInsn(GETSTATIC, GEN_INTERNAL, "fails", "I");
        mv.visitInsn(ICONST_1);
        mv.visitInsn(IADD);
        mv.visitFieldInsn(PUTSTATIC, GEN_INTERNAL, "fails", "I");
        mv.visitLabel(ok);
        mv.visitInsn(RETURN);
        mv.visitMaxs(0, 0);
        mv.visitEnd();
    }

    private static void emitBoundsOk(ClassWriter cw) {
        MethodVisitor mv = cw.visitMethod(ACC_PRIVATE | ACC_STATIC, "boundsOk", "()Z", null, null);
        mv.visitCode();
        Label start = new Label();
        Label end = new Label();
        Label handler = new Label();
        mv.visitTryCatchBlock(start, end, handler, "java/lang/IndexOutOfBoundsException");
        mv.visitLabel(start);
        mv.visitInsn(ICONST_1);
        mv.visitTypeInsn(ANEWARRAY, "java/lang/Object");
        mv.visitInsn(DUP);
        mv.visitInsn(ICONST_0);
        mv.visitLdcInsn("x");
        mv.visitInsn(AASTORE);
        mv.visitMethodInsn(INVOKESTATIC, "lmx/LmxOccurrence", "independent", "([Ljava/lang/Object;)Llmx/LmxOccurrence;", false);
        mv.visitInsn(ICONST_1);
        mv.visitMethodInsn(INVOKEVIRTUAL, "lmx/LmxOccurrence", "child", "(I)Ljava/lang/Object;", false);
        mv.visitInsn(POP);
        mv.visitInsn(ICONST_0);
        mv.visitLabel(end);
        Label exit = new Label();
        mv.visitJumpInsn(GOTO, exit);
        mv.visitLabel(handler);
        mv.visitInsn(POP);
        mv.visitInsn(ICONST_1);
        mv.visitLabel(exit);
        mv.visitInsn(IRETURN);
        mv.visitMaxs(0, 0);
        mv.visitEnd();
    }

    private static void emitFieldFollowOk(ClassWriter cw) {
        MethodVisitor mv = cw.visitMethod(ACC_PRIVATE | ACC_STATIC, "fieldFollowOk", "()Z", null, null);
        mv.visitCode();
        mv.visitInsn(ICONST_1);
        mv.visitTypeInsn(ANEWARRAY, "java/lang/Object");
        mv.visitInsn(DUP);
        mv.visitInsn(ICONST_0);
        mv.visitLdcInsn("v");
        mv.visitInsn(AASTORE);
        mv.visitMethodInsn(INVOKESTATIC, "lmx/LmxOccurrence", "independent", "([Ljava/lang/Object;)Llmx/LmxOccurrence;", false);
        mv.visitInsn(ICONST_0);
        mv.visitMethodInsn(INVOKEVIRTUAL, "lmx/LmxOccurrence", "child", "(I)Ljava/lang/Object;", false);
        mv.visitLdcInsn("v");
        mv.visitMethodInsn(INVOKEVIRTUAL, "java/lang/Object", "equals", "(Ljava/lang/Object;)Z", false);
        mv.visitInsn(IRETURN);
        mv.visitMaxs(0, 0);
        mv.visitEnd();
    }

    private static void emitMergeOk(ClassWriter cw) {
        MethodVisitor mv = cw.visitMethod(ACC_PRIVATE | ACC_STATIC, "mergeOk", "()Z", null, null);
        mv.visitCode();
        mv.visitInsn(ICONST_1);
        mv.visitTypeInsn(ANEWARRAY, "java/lang/Object");
        mv.visitInsn(DUP);
        mv.visitInsn(ICONST_0);
        mv.visitLdcInsn("L");
        mv.visitInsn(AASTORE);
        mv.visitMethodInsn(INVOKESTATIC, "lmx/LmxOccurrence", "independent", "([Ljava/lang/Object;)Llmx/LmxOccurrence;", false);
        mv.visitVarInsn(ASTORE, 0);
        mv.visitInsn(ICONST_1);
        mv.visitTypeInsn(ANEWARRAY, "java/lang/Object");
        mv.visitInsn(DUP);
        mv.visitInsn(ICONST_0);
        mv.visitLdcInsn("R");
        mv.visitInsn(AASTORE);
        mv.visitMethodInsn(INVOKESTATIC, "lmx/LmxOccurrence", "independent", "([Ljava/lang/Object;)Llmx/LmxOccurrence;", false);
        mv.visitVarInsn(ASTORE, 1);
        mv.visitInsn(ICONST_2);
        mv.visitTypeInsn(ANEWARRAY, "lmx/LmxOccurrence");
        mv.visitInsn(DUP);
        mv.visitInsn(ICONST_0);
        mv.visitVarInsn(ALOAD, 0);
        mv.visitInsn(AASTORE);
        mv.visitInsn(DUP);
        mv.visitInsn(ICONST_1);
        mv.visitVarInsn(ALOAD, 1);
        mv.visitInsn(AASTORE);
        mv.visitMethodInsn(INVOKESTATIC, "lmx/LmxOccurrence", "merge", "([Llmx/LmxOccurrence;)Llmx/LmxOccurrence;", false);
        mv.visitVarInsn(ASTORE, 2);
        mv.visitVarInsn(ALOAD, 2);
        mv.visitMethodInsn(INVOKEVIRTUAL, "lmx/LmxOccurrence", "len", "()I", false);
        mv.visitInsn(ICONST_2);
        Label bad = new Label();
        mv.visitJumpInsn(IF_ICMPNE, bad);
        mv.visitVarInsn(ALOAD, 2);
        mv.visitMethodInsn(INVOKEVIRTUAL, "lmx/LmxOccurrence", "node", "()Llmx/LmxOccurrence;", false);
        mv.visitJumpInsn(IFNONNULL, bad);
        mv.visitInsn(ICONST_1);
        mv.visitInsn(IRETURN);
        mv.visitLabel(bad);
        mv.visitInsn(ICONST_0);
        mv.visitInsn(IRETURN);
        mv.visitMaxs(0, 0);
        mv.visitEnd();
    }

    private static void emitNestedOk(ClassWriter cw) {
        MethodVisitor mv = cw.visitMethod(ACC_PRIVATE | ACC_STATIC, "nestedOk", "()Z", null, null);
        mv.visitCode();
        mv.visitInsn(ICONST_0);
        mv.visitTypeInsn(ANEWARRAY, "java/lang/Object");
        mv.visitMethodInsn(INVOKESTATIC, "lmx/LmxOccurrence", "independent", "([Ljava/lang/Object;)Llmx/LmxOccurrence;", false);
        mv.visitVarInsn(ASTORE, 0);
        mv.visitVarInsn(ALOAD, 0);
        mv.visitInsn(ICONST_1);
        mv.visitTypeInsn(ANEWARRAY, "java/lang/Object");
        mv.visitInsn(DUP);
        mv.visitInsn(ICONST_0);
        mv.visitLdcInsn("x");
        mv.visitInsn(AASTORE);
        mv.visitMethodInsn(INVOKESTATIC, "lmx/LmxOccurrence", "nested", "(Llmx/LmxOccurrence;[Ljava/lang/Object;)Llmx/LmxOccurrence;", false);
        mv.visitMethodInsn(INVOKEVIRTUAL, "lmx/LmxOccurrence", "node", "()Llmx/LmxOccurrence;", false);
        mv.visitVarInsn(ALOAD, 0);
        Label good = new Label();
        mv.visitJumpInsn(IF_ACMPEQ, good);
        mv.visitInsn(ICONST_0);
        mv.visitInsn(IRETURN);
        mv.visitLabel(good);
        mv.visitInsn(ICONST_1);
        mv.visitInsn(IRETURN);
        mv.visitMaxs(0, 0);
        mv.visitEnd();
    }
}
