package printer;

import graph.L3Node;
import graph.L3Role;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.BitSet;
import java.util.IdentityHashMap;
import java.util.List;
import java.util.Map;
import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.Label;
import org.objectweb.asm.MethodVisitor;
import org.objectweb.asm.Opcodes;

/**
 * Emits one JVM method per reachable {@link L3Role#CALLABLE}.
 * Method names {@code c0}..{@code cN}; descriptors from arity; activation-local
 * int slots after subject/args. Pre-test WHILE; BREAK/CONTINUE/REDO via loop-label stack;
 * nested RETURN exits the current CALLABLE (IRETURN). Self/mutual recursive CALL
 * via physical CALLABLE identity (INVOKESTATIC to mapped method).
 * Ownership cycles among non-CALLABLE expression nodes are rejected with gray/black
 * identity DFS before emission; CALLABLE reference edges remain non-ownership.
 */


public final class L3ClassfilePrinter implements Opcodes {
    public static final String GEN_INTERNAL = "lmx/gen/PrintedL3Expr";
    public static final String EVAL = "eval";

    /** Compile-time nearest-WHILE nesting for BREAK/CONTINUE validation. */
    private static final ThreadLocal<Integer> LOOP_DEPTH =
            new ThreadLocal<Integer>() {
                @Override
                protected Integer initialValue() {
                    return Integer.valueOf(0);
                }
            };
    /** Emit-time label stack: each frame is {condLabel, breakLabel, bodyLabel}. */
    private static final ThreadLocal<ArrayDeque<Label[]>> LOOP_STACK =
            new ThreadLocal<ArrayDeque<Label[]>>() {
                @Override
                protected ArrayDeque<Label[]> initialValue() {
                    return new ArrayDeque<Label[]>();
                }
            };
    /** Compile-time active physical loop labels in the current CALLABLE (identity). */
    private static final ThreadLocal<IdentityHashMap<L3Node, Boolean>> ACTIVE_LOOP_LABELS =
            new ThreadLocal<IdentityHashMap<L3Node, Boolean>>() {
                @Override
                protected IdentityHashMap<L3Node, Boolean> initialValue() {
                    return new IdentityHashMap<L3Node, Boolean>();
                }
            };
    /** Emit-time map from physical LOOP_LABEL node to its WHILE frame. */
    private static final ThreadLocal<IdentityHashMap<L3Node, Label[]>> LABEL_FRAMES =
            new ThreadLocal<IdentityHashMap<L3Node, Label[]>>() {
                @Override
                protected IdentityHashMap<L3Node, Label[]> initialValue() {
                    return new IdentityHashMap<L3Node, Label[]>();
                }
            };
    /** Compile-time nearest-RETRYABLE nesting for RETRY validation. */
    private static final ThreadLocal<Integer> RETRY_DEPTH =
            new ThreadLocal<Integer>() {
                @Override
                protected Integer initialValue() {
                    return Integer.valueOf(0);
                }
            };
    /** Compile-time active physical retry labels in the current CALLABLE (identity). */
    private static final ThreadLocal<IdentityHashMap<L3Node, Boolean>> ACTIVE_RETRY_LABELS =
            new ThreadLocal<IdentityHashMap<L3Node, Boolean>>() {
                @Override
                protected IdentityHashMap<L3Node, Boolean> initialValue() {
                    return new IdentityHashMap<L3Node, Boolean>();
                }
            };
    /** Emit-time stack of RETRYABLE body-entry labels (nearest = peekFirst). */
    private static final ThreadLocal<ArrayDeque<Label>> RETRY_STACK =
            new ThreadLocal<ArrayDeque<Label>>() {
                @Override
                protected ArrayDeque<Label> initialValue() {
                    return new ArrayDeque<Label>();
                }
            };
    /** Emit-time map from physical RETRY_LABEL node to its RETRYABLE body-entry label. */
    private static final ThreadLocal<IdentityHashMap<L3Node, Label>> RETRY_LABEL_FRAMES =
            new ThreadLocal<IdentityHashMap<L3Node, Label>>() {
                @Override
                protected IdentityHashMap<L3Node, Label> initialValue() {
                    return new IdentityHashMap<L3Node, Label>();
                }
            };

    private L3ClassfilePrinter() {}

    public static byte[] emitCallable(L3Node entry) {
        if (entry == null || entry.role != L3Role.CALLABLE) {
            throw new IllegalArgumentException("expected CALLABLE root");
        }
        requireSealed(entry);
        LOOP_DEPTH.set(Integer.valueOf(0));
        LOOP_STACK.get().clear();
        ACTIVE_LOOP_LABELS.get().clear();
        LABEL_FRAMES.get().clear();
        RETRY_DEPTH.set(Integer.valueOf(0));
        RETRY_STACK.get().clear();
        ACTIVE_RETRY_LABELS.get().clear();
        RETRY_LABEL_FRAMES.get().clear();
        List<L3Node> order = new ArrayList<L3Node>();
        Map<L3Node, Integer> map = new IdentityHashMap<L3Node, Integer>();
        collectCallables(entry, order, map);

        Map<L3Node, Integer> arity = new IdentityHashMap<L3Node, Integer>();
        Map<L3Node, Integer> slots = new IdentityHashMap<L3Node, Integer>();
        for (L3Node c : order) {
            arity.put(c, Integer.valueOf(computeArity(c)));
            slots.put(c, Integer.valueOf(computeSlotCount(c)));
        }
        validateAll(order, map, arity, slots);

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
            emitOneCallable(cw, order.get(i), i, map, arity, slots);
        }

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

    static int computeArity(L3Node callable) {
        int[] maxIdx = new int[] {-1};
        scanArity(callable.child(0), maxIdx);
        if (maxIdx[0] < 0) {
            return 1;
        }
        return maxIdx[0] + 1;
    }

    /** Slot count from LOCAL_SET indices only (max index + 1). */
    static int computeSlotCount(L3Node callable) {
        int[] maxIdx = new int[] {-1};
        scanSlots(callable.child(0), maxIdx);
        if (maxIdx[0] < 0) {
            return 0;
        }
        return maxIdx[0] + 1;
    }

    private static String ownershipRoleCategory(L3Role r) {
        if (r == L3Role.SEQUENCE) {
            return "SEQUENCE";
        }
        if (r == L3Role.ADD) {
            return "ADD";
        }
        if (r == L3Role.IF) {
            return "IF";
        }
        if (r == L3Role.WHILE) {
            return "WHILE";
        }
        if (r == L3Role.REDO) {
            return "REDO";
        }
        if (r == L3Role.LOOP_LABEL) {
            return "LOOP_LABEL";
        }
        if (r == L3Role.RETRY_LABEL) {
            return "RETRY_LABEL";
        }
        if (r == L3Role.RETRYABLE) {
            return "RETRYABLE";
        }
        if (r == L3Role.RETRY) {
            return "RETRY";
        }
        if (r == L3Role.CALL) {
            return "CALL";
        }
        if (r == L3Role.RETURN) {
            return "RETURN";
        }
        if (r == L3Role.LOCAL_SET) {
            return "LOCAL_SET";
        }
        if (r == L3Role.LOCAL_GET) {
            return "LOCAL_GET";
        }
        return "EXPR";
    }


    private static boolean isLoopTransfer(L3Role r) {
        return r == L3Role.BREAK || r == L3Role.CONTINUE || r == L3Role.REDO;
    }

    private static void requireLoopLabelNode(L3Node n) {
        if (n == null || n.role != L3Role.LOOP_LABEL) {
            throw new IllegalArgumentException(
                    n != null && n.role == L3Role.RETRY_LABEL
                            ? "loop label target must be LOOP_LABEL node (not RETRY_LABEL)"
                            : "loop label target must be LOOP_LABEL node");
        }
        if (n.childCount() != 0) {
            throw new IllegalArgumentException("LOOP_LABEL arity");
        }
    }

    private static void requireRetryLabelNode(L3Node n) {
        if (n == null || n.role != L3Role.RETRY_LABEL) {
            throw new IllegalArgumentException(
                    n != null && n.role == L3Role.LOOP_LABEL
                            ? "retry label target must be RETRY_LABEL node (not LOOP_LABEL)"
                            : "retry label target must be RETRY_LABEL node");
        }
        if (n.childCount() != 0) {
            throw new IllegalArgumentException("RETRY_LABEL arity");
        }
    }

    private static L3Node transferLabelOrNull(L3Node expr) {
        if (expr.childCount() == 0) {
            return null;
        }
        if (expr.childCount() != 1) {
            throw new IllegalArgumentException(
                    expr.role == L3Role.BREAK
                            ? "BREAK arity"
                            : (expr.role == L3Role.CONTINUE ? "CONTINUE arity" : "REDO arity"));
        }
        requireLoopLabelNode(expr.child(0));
        return expr.child(0);
    }

    private static L3Node whileLabelOrNull(L3Node whileNode) {
        int n = whileNode.childCount();
        if (n == 2) {
            return null;
        }
        if (n != 3) {
            throw new IllegalArgumentException("WHILE arity: need condition, body[, label]");
        }
        requireLoopLabelNode(whileNode.child(2));
        return whileNode.child(2);
    }


    private static L3Node retryTransferLabelOrNull(L3Node expr) {
        if (expr.childCount() == 0) {
            return null;
        }
        if (expr.childCount() != 1) {
            throw new IllegalArgumentException("RETRY arity");
        }
        requireRetryLabelNode(expr.child(0));
        return expr.child(0);
    }

    private static L3Node retryableLabelOrNull(L3Node retryable) {
        int n = retryable.childCount();
        if (n == 1) {
            return null;
        }
        if (n != 2) {
            throw new IllegalArgumentException("RETRYABLE arity: need body[, RETRY_LABEL]");
        }
        requireRetryLabelNode(retryable.child(1));
        return retryable.child(1);
    }

    private static void ownershipGrayEnter(L3Node n, Map<L3Node, Boolean> gray) {
        if (gray.containsKey(n)) {
            throw new IllegalArgumentException(
                    "ownership cycle: gray back-edge at " + ownershipRoleCategory(n.role));
        }
        gray.put(n, Boolean.TRUE);
    }

    private static void scanArity(L3Node n, int[] maxIdx) {
        scanArity(
                n,
                maxIdx,
                new IdentityHashMap<L3Node, Boolean>(),
                new IdentityHashMap<L3Node, Boolean>());
    }

    private static void scanArity(
            L3Node n, int[] maxIdx, Map<L3Node, Boolean> gray, Map<L3Node, Boolean> black) {
        if (n == null) {
            return;
        }
        if (n.role == L3Role.CALLABLE) {
            return;
        }
        if (black.containsKey(n)) {
            return;
        }
        ownershipGrayEnter(n, gray);
        try {
            if (n.role == L3Role.ARG) {
                if (n.intPayload > maxIdx[0]) {
                    maxIdx[0] = n.intPayload;
                }
                return;
            }
            if (n.role == L3Role.CALL) {
                for (int i = 1; i < n.childCount(); i++) {
                    scanArity(n.child(i), maxIdx, gray, black);
                }
                return;
            }
            if (n.role == L3Role.RETRYABLE) {
                if (n.childCount() < 1) {
                    throw new IllegalArgumentException("RETRYABLE arity: need body[, RETRY_LABEL]");
                }
                scanArity(n.child(0), maxIdx, gray, black);
                return;
            }
            if (n.role == L3Role.RETRY) {
                return;
            }
            for (int _i_c = 0; _i_c < n.childCount(); _i_c++) {
                scanArity(n.child(_i_c), maxIdx, gray, black);
            }
        } finally {
            gray.remove(n);
            black.put(n, Boolean.TRUE);
        }
    }

    private static void scanSlots(L3Node n, int[] maxIdx) {
        scanSlots(
                n,
                maxIdx,
                new IdentityHashMap<L3Node, Boolean>(),
                new IdentityHashMap<L3Node, Boolean>());
    }

    private static void scanSlots(
            L3Node n, int[] maxIdx, Map<L3Node, Boolean> gray, Map<L3Node, Boolean> black) {
        if (n == null) {
            return;
        }
        if (n.role == L3Role.CALLABLE) {
            return;
        }
        if (black.containsKey(n)) {
            return;
        }
        ownershipGrayEnter(n, gray);
        try {
            if (n.role == L3Role.LOCAL_SET) {
                if (n.intPayload > maxIdx[0]) {
                    maxIdx[0] = n.intPayload;
                }
                for (int _i_c = 0; _i_c < n.childCount(); _i_c++) {
                    scanSlots(n.child(_i_c), maxIdx, gray, black);
                }
                return;
            }
            if (n.role == L3Role.CALL) {
                for (int i = 1; i < n.childCount(); i++) {
                    scanSlots(n.child(i), maxIdx, gray, black);
                }
                return;
            }
            if (n.role == L3Role.RETRYABLE) {
                if (n.childCount() < 1) {
                    throw new IllegalArgumentException("RETRYABLE arity: need body[, RETRY_LABEL]");
                }
                scanSlots(n.child(0), maxIdx, gray, black);
                return;
            }
            if (n.role == L3Role.RETRY) {
                return;
            }
            for (int _i_c = 0; _i_c < n.childCount(); _i_c++) {
                scanSlots(n.child(_i_c), maxIdx, gray, black);
            }
        } finally {
            gray.remove(n);
            black.put(n, Boolean.TRUE);
        }
    }

    private static void collectCallables(L3Node entry, List<L3Node> order, Map<L3Node, Integer> map) {
        walk(
                entry,
                order,
                map,
                new IdentityHashMap<L3Node, Boolean>(),
                new IdentityHashMap<L3Node, Boolean>());
    }

    private static void walk(
            L3Node n,
            List<L3Node> order,
            Map<L3Node, Integer> map,
            Map<L3Node, Boolean> gray,
            Map<L3Node, Boolean> black) {
        if (n == null) {
            return;
        }
        if (n.role == L3Role.CALLABLE) {
            if (map.containsKey(n)) {
                return;
            }
            requireSealed(n);
            map.put(n, Integer.valueOf(order.size()));
            order.add(n);
            ownershipGrayEnter(n, gray);
            try {
                for (int _i_c = 0; _i_c < n.childCount(); _i_c++) {
                    walk(n.child(_i_c), order, map, gray, black);
                }
            } finally {
                gray.remove(n);
                black.put(n, Boolean.TRUE);
            }
            return;
        }
        if (black.containsKey(n)) {
            return;
        }
        ownershipGrayEnter(n, gray);
        try {
            if (n.role == L3Role.CALL) {
                if (n.childCount() < 1) {
                    throw new IllegalArgumentException("CALL needs callee child");
                }
                L3Node callee = n.child(0);
                if (callee == null || callee.role != L3Role.CALLABLE) {
                    throw new IllegalArgumentException("CALL callee must be CALLABLE node");
                }
                walk(callee, order, map, gray, black);
                for (int i = 1; i < n.childCount(); i++) {
                    walk(n.child(i), order, map, gray, black);
                }
                return;
            }
            if (n.role == L3Role.RETRYABLE) {
                if (n.childCount() < 1) {
                    throw new IllegalArgumentException("RETRYABLE arity: need body[, RETRY_LABEL]");
                }
                walk(n.child(0), order, map, gray, black);
                return;
            }
            if (n.role == L3Role.RETRY) {
                return;
            }
            for (int _i_c = 0; _i_c < n.childCount(); _i_c++) {
                walk(n.child(_i_c), order, map, gray, black);
            }
        } finally {
            gray.remove(n);
            black.put(n, Boolean.TRUE);
        }
    }

    private static void requireSealed(L3Node callable) {
        if (callable == null || callable.role != L3Role.CALLABLE) {
            throw new IllegalArgumentException("expected CALLABLE");
        }
        if (!callable.isSealed()) {
            throw new IllegalStateException("unsealed CALLABLE");
        }
        if (callable.childCount() != 1 || callable.child(0) == null) {
            throw new IllegalStateException("unsealed/unresolved CALLABLE body");
        }
    }

    private static void validateAll(
            List<L3Node> order,
            Map<L3Node, Integer> map,
            Map<L3Node, Integer> arity,
            Map<L3Node, Integer> slots) {
        for (L3Node c : order) {
            requireSealed(c);
            if (c.childCount() != 1 || c.child(0).role != L3Role.RETURN) {
                throw new IllegalArgumentException("CALLABLE body must be a single RETURN");
            }
            L3Node ret = c.child(0);
            if (ret.childCount() != 1) {
                throw new IllegalArgumentException("RETURN arity: need exactly one value");
            }
            validateIntExpr(
                    ret.child(0),
                    map,
                    arity,
                    slots,
                    c,
                    arity.get(c).intValue(),
                    slots.get(c).intValue(),
                    new BitSet());
        }
    }

    private static BitSet validateIntExpr(
            L3Node expr,
            Map<L3Node, Integer> map,
            Map<L3Node, Integer> arity,
            Map<L3Node, Integer> slots,
            L3Node currentCallable,
            int currentArity,
            int slotCount,
            BitSet assigned) {
        return validateIntExpr(
                expr,
                map,
                arity,
                slots,
                currentCallable,
                currentArity,
                slotCount,
                assigned,
                new IdentityHashMap<L3Node, Boolean>());
    }

    private static BitSet validateIntExpr(
            L3Node expr,
            Map<L3Node, Integer> map,
            Map<L3Node, Integer> arity,
            Map<L3Node, Integer> slots,
            L3Node currentCallable,
            int currentArity,
            int slotCount,
            BitSet assigned,
            Map<L3Node, Boolean> gray) {
        ownershipGrayEnter(expr, gray);
        try {
            return validateIntExprBody(
                    expr, map, arity, slots, currentCallable, currentArity, slotCount, assigned, gray);
        } finally {
            gray.remove(expr);
        }
    }

    private static BitSet validateIntExprBody(
            L3Node expr,
            Map<L3Node, Integer> map,
            Map<L3Node, Integer> arity,
            Map<L3Node, Integer> slots,
            L3Node currentCallable,
            int currentArity,
            int slotCount,
            BitSet assigned,
            Map<L3Node, Boolean> gray) {
        L3Role r = expr.role;
        if (r == L3Role.INT_LITERAL || r == L3Role.PROBE) {
            return assigned;
        }
        if (r == L3Role.ARG) {
            int idx = expr.intPayload;
            if (idx < 1) {
                throw new IllegalArgumentException("ARG out of range for int context (need >= 1)");
            }
            if (idx >= currentArity) {
                throw new IllegalArgumentException("ARG out of range");
            }
            return assigned;
        }
        if (r == L3Role.LOCAL_GET) {
            int idx = expr.intPayload;
            if (idx < 0) {
                throw new IllegalArgumentException("LOCAL_GET negative slot");
            }
            if (idx >= slotCount) {
                throw new IllegalArgumentException("LOCAL_GET out of range");
            }
            if (!assigned.get(idx)) {
                throw new IllegalArgumentException("LOCAL_GET uninitialized");
            }
            if (expr.childCount() != 0) {
                throw new IllegalArgumentException("LOCAL_GET arity");
            }
            return assigned;
        }
        if (r == L3Role.LOCAL_SET) {
            int idx = expr.intPayload;
            if (idx < 0) {
                throw new IllegalArgumentException("LOCAL_SET negative slot");
            }
            if (idx >= slotCount) {
                throw new IllegalArgumentException("LOCAL_SET out of range");
            }
            if (expr.childCount() != 1) {
                throw new IllegalArgumentException("LOCAL_SET arity: need RHS");
            }
            BitSet afterRhs = validateIntExpr(
                    expr.child(0), map, arity, slots, currentCallable, currentArity, slotCount, assigned, gray);
            BitSet next = (BitSet) afterRhs.clone();
            next.set(idx);
            return next;
        }
        if (r == L3Role.SEQUENCE) {
            if (expr.childCount() < 1) {
                throw new IllegalArgumentException("SEQUENCE arity: need >= 1 child");
            }
            BitSet a = assigned;
            for (int i = 0; i < expr.childCount() - 1; i++) {
                a = validateStmt(
                        expr.child(i), map, arity, slots, currentCallable, currentArity, slotCount, a);
            }
            return validateIntExpr(
                    expr.child(expr.childCount() - 1),
                    map,
                    arity,
                    slots,
                    currentCallable,
                    currentArity,
                    slotCount,
                    a, gray);
        }
        if (r == L3Role.RETURN) {
            return validateNestedReturn(
                    expr, map, arity, slots, currentCallable, currentArity, slotCount, assigned);
        }
        if (r == L3Role.WHILE) {
            throw new IllegalArgumentException("WHILE not allowed in value context");
        }
        if (r == L3Role.BREAK) {
            throw new IllegalArgumentException("BREAK not allowed in value context");
        }
        if (r == L3Role.CONTINUE) {
            throw new IllegalArgumentException("CONTINUE not allowed in value context");
        }
        if (r == L3Role.REDO) {
            throw new IllegalArgumentException("REDO not allowed in value context");
        }
        if (r == L3Role.LOOP_LABEL) {
            throw new IllegalArgumentException("LOOP_LABEL not allowed in value context");
        }
        if (r == L3Role.RETRY_LABEL) {
            throw new IllegalArgumentException("RETRY_LABEL not allowed in value context");
        }
        if (r == L3Role.RETRYABLE) {
            throw new IllegalArgumentException("RETRYABLE not allowed in value context");
        }
        if (r == L3Role.RETRY) {
            throw new IllegalArgumentException("RETRY not allowed in value context");
        }
        if (r == L3Role.FIELD_FOLLOW) {
            if (expr.childCount() != 1) {
                throw new IllegalArgumentException("FIELD_FOLLOW arity");
            }
            validateOccurrence(expr.child(0), currentArity);
            return assigned;
        }
        if (r == L3Role.ADD) {
            if (expr.childCount() != 2) {
                throw new IllegalArgumentException("ADD arity");
            }
            BitSet a = validateIntExpr(
                    expr.child(0), map, arity, slots, currentCallable, currentArity, slotCount, assigned, gray);
            return validateIntExpr(
                    expr.child(1), map, arity, slots, currentCallable, currentArity, slotCount, a, gray);
        }
        if (r == L3Role.CALL) {
            if (expr.childCount() < 2) {
                throw new IllegalArgumentException("CALL arity: need callee + subject arg");
            }
            L3Node callee = expr.child(0);
            if (callee == null || callee.role != L3Role.CALLABLE) {
                throw new IllegalArgumentException("CALL callee must be CALLABLE");
            }
            requireSealed(callee);
            if (!map.containsKey(callee)) {
                throw new IllegalArgumentException("CALL callee not reachable/mapped");
            }
            int need = arity.get(callee).intValue();
            int got = expr.childCount() - 1;
            if (got != need) {
                throw new IllegalArgumentException(
                        "CALL arg count mismatch: need " + need + " got " + got);
            }
            validateOccurrence(expr.child(1), currentArity);
            BitSet a = assigned;
            for (int i = 2; i < expr.childCount(); i++) {
                a = validateIntExpr(
                        expr.child(i), map, arity, slots, currentCallable, currentArity, slotCount, a, gray);
            }
            return a;
        }
        if (r == L3Role.IF) {
            if (expr.childCount() != 3) {
                throw new IllegalArgumentException("IF arity: need condition, then, else");
            }
            BitSet afterCond = validateIntExpr(
                    expr.child(0), map, arity, slots, currentCallable, currentArity, slotCount, assigned, gray);
            BitSet thenA = validateIntExpr(
                    expr.child(1),
                    map,
                    arity,
                    slots,
                    currentCallable,
                    currentArity,
                    slotCount,
                    (BitSet) afterCond.clone(), gray);
            BitSet elseA = validateIntExpr(
                    expr.child(2),
                    map,
                    arity,
                    slots,
                    currentCallable,
                    currentArity,
                    slotCount,
                    (BitSet) afterCond.clone(), gray);
            thenA.and(elseA);
            return thenA;
        }
        if (r == L3Role.CALLABLE) {
            throw new IllegalArgumentException(
                    "malformed structural cycle: CALLABLE is not an int expression");
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

    /**
     * Statement position: WHILE / BREAK / CONTINUE / REDO / RETRYABLE / RETRY / RETURN / stmt-SEQUENCE / stmt-IF,
     * or a discarded int expression.
     */
    private static BitSet validateStmt(
            L3Node expr,
            Map<L3Node, Integer> map,
            Map<L3Node, Integer> arity,
            Map<L3Node, Integer> slots,
            L3Node currentCallable,
            int currentArity,
            int slotCount,
            BitSet assigned) {
        L3Role r = expr.role;
        if (r == L3Role.RETURN) {
            return validateNestedReturn(
                    expr, map, arity, slots, currentCallable, currentArity, slotCount, assigned);
        }
        if (r == L3Role.BREAK || r == L3Role.CONTINUE || r == L3Role.REDO) {
            if (expr.intPayload != 0) {
                throw new IllegalArgumentException(
                        r == L3Role.REDO ? "REDO payload" : "loop transfer payload");
            }
            L3Node lab = transferLabelOrNull(expr);
            if (lab == null) {
                if (LOOP_DEPTH.get().intValue() < 1) {
                    throw new IllegalArgumentException(
                            r == L3Role.BREAK
                                    ? "BREAK outside loop"
                                    : (r == L3Role.CONTINUE
                                            ? "CONTINUE outside loop"
                                            : "REDO outside loop"));
                }
            } else if (!ACTIVE_LOOP_LABELS.get().containsKey(lab)) {
                throw new IllegalArgumentException("loop label not visible in this CALLABLE");
            }
            return assigned;
        }
        if (r == L3Role.RETRY) {
            if (expr.intPayload != 0) {
                throw new IllegalArgumentException("RETRY payload");
            }
            L3Node lab = retryTransferLabelOrNull(expr);
            if (lab == null) {
                if (RETRY_DEPTH.get().intValue() < 1) {
                    throw new IllegalArgumentException("RETRY outside region");
                }
            } else if (!ACTIVE_RETRY_LABELS.get().containsKey(lab)) {
                throw new IllegalArgumentException("retry label not visible in this CALLABLE");
            }
            return assigned;
        }
        if (r == L3Role.RETRYABLE) {
            if (expr.intPayload != 0) {
                throw new IllegalArgumentException("RETRYABLE payload");
            }
            L3Node lab = retryableLabelOrNull(expr);
            if (lab != null) {
                if (ACTIVE_RETRY_LABELS.get().containsKey(lab)) {
                    throw new IllegalArgumentException("duplicate active retry label binding");
                }
                ACTIVE_RETRY_LABELS.get().put(lab, Boolean.TRUE);
            }
            RETRY_DEPTH.set(Integer.valueOf(RETRY_DEPTH.get().intValue() + 1));
            try {
                validateStmt(
                        expr.child(0),
                        map,
                        arity,
                        slots,
                        currentCallable,
                        currentArity,
                        slotCount,
                        assigned);
            } finally {
                RETRY_DEPTH.set(Integer.valueOf(RETRY_DEPTH.get().intValue() - 1));
                if (lab != null) {
                    ACTIVE_RETRY_LABELS.get().remove(lab);
                }
            }
            return assigned;
        }
        if (r == L3Role.WHILE) {
            L3Node lab = whileLabelOrNull(expr);
            BitSet afterCond = validateIntExpr(
                    expr.child(0), map, arity, slots, currentCallable, currentArity, slotCount, assigned);
            if (lab != null) {
                if (ACTIVE_LOOP_LABELS.get().containsKey(lab)) {
                    throw new IllegalArgumentException("duplicate active loop label binding");
                }
                ACTIVE_LOOP_LABELS.get().put(lab, Boolean.TRUE);
            }
            LOOP_DEPTH.set(Integer.valueOf(LOOP_DEPTH.get().intValue() + 1));
            try {
                validateStmt(
                        expr.child(1),
                        map,
                        arity,
                        slots,
                        currentCallable,
                        currentArity,
                        slotCount,
                        (BitSet) afterCond.clone());
            } finally {
                LOOP_DEPTH.set(Integer.valueOf(LOOP_DEPTH.get().intValue() - 1));
                if (lab != null) {
                    ACTIVE_LOOP_LABELS.get().remove(lab);
                }
            }
            return assigned;
        }
        if (r == L3Role.SEQUENCE) {
            if (expr.childCount() < 1) {
                throw new IllegalArgumentException("SEQUENCE arity: need >= 1 child");
            }
            BitSet a = assigned;
            for (int i = 0; i < expr.childCount(); i++) {
                a = validateStmt(
                        expr.child(i), map, arity, slots, currentCallable, currentArity, slotCount, a);
            }
            return a;
        }
        if (r == L3Role.IF) {
            if (expr.childCount() != 3) {
                throw new IllegalArgumentException("IF arity: need condition, then, else");
            }
            BitSet afterCond = validateIntExpr(
                    expr.child(0), map, arity, slots, currentCallable, currentArity, slotCount, assigned);
            BitSet thenA = validateStmt(
                    expr.child(1),
                    map,
                    arity,
                    slots,
                    currentCallable,
                    currentArity,
                    slotCount,
                    (BitSet) afterCond.clone());
            BitSet elseA = validateStmt(
                    expr.child(2),
                    map,
                    arity,
                    slots,
                    currentCallable,
                    currentArity,
                    slotCount,
                    (BitSet) afterCond.clone());
            thenA.and(elseA);
            return thenA;
        }
        return validateIntExpr(
                expr, map, arity, slots, currentCallable, currentArity, slotCount, assigned);
    }


    /**
     * Nested RETURN: validate value once; mark all slots assigned (path exits callable).
     * The CALLABLE root wrapper is validated separately; this covers nested uses only.
     */
    private static BitSet validateNestedReturn(
            L3Node expr,
            Map<L3Node, Integer> map,
            Map<L3Node, Integer> arity,
            Map<L3Node, Integer> slots,
            L3Node currentCallable,
            int currentArity,
            int slotCount,
            BitSet assigned) {
        if (currentCallable == null) {
            throw new IllegalArgumentException("RETURN outside callable");
        }
        if (expr.childCount() != 1) {
            throw new IllegalArgumentException("RETURN arity: need exactly one value");
        }
        BitSet after = validateIntExpr(
                expr.child(0), map, arity, slots, currentCallable, currentArity, slotCount, assigned);
        BitSet exited = (BitSet) after.clone();
        for (int i = 0; i < slotCount; i++) {
            exited.set(i);
        }
        return exited;
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
            Map<L3Node, Integer> arity,
            Map<L3Node, Integer> slots) {
        int ar = arity.get(callable).intValue();
        String name = "c" + index;
        String desc = descriptor(ar);
        MethodVisitor mv = cw.visitMethod(ACC_PUBLIC | ACC_STATIC, name, desc, null, null);
        mv.visitCode();
        L3Node ret = callable.child(0);
        emitIntExpr(mv, ret.child(0), map, arity, ar);
        mv.visitInsn(IRETURN);
        mv.visitMaxs(0, 0);
        mv.visitEnd();
    }

    private static int jvmLocal(int arity, int slot) {
        return arity + slot;
    }

    private static void emitIntExpr(
            MethodVisitor mv,
            L3Node expr,
            Map<L3Node, Integer> map,
            Map<L3Node, Integer> arity,
            int currentArity) {
        L3Role r = expr.role;
        if (r == L3Role.INT_LITERAL) {
            mv.visitLdcInsn(Integer.valueOf(expr.intPayload));
        } else if (r == L3Role.PROBE) {
            mv.visitMethodInsn(INVOKESTATIC, "graph/ArgEvalCounter", "tick", "()I", false);
        } else if (r == L3Role.ARG) {
            mv.visitVarInsn(ILOAD, expr.intPayload);
        } else if (r == L3Role.LOCAL_GET) {
            mv.visitVarInsn(ILOAD, jvmLocal(currentArity, expr.intPayload));
        } else if (r == L3Role.LOCAL_SET) {
            emitIntExpr(mv, expr.child(0), map, arity, currentArity);
            mv.visitInsn(DUP);
            mv.visitVarInsn(ISTORE, jvmLocal(currentArity, expr.intPayload));
        } else if (r == L3Role.SEQUENCE) {
            for (int i = 0; i < expr.childCount() - 1; i++) {
                emitStmt(mv, expr.child(i), map, arity, currentArity);
            }
            emitIntExpr(mv, expr.child(expr.childCount() - 1), map, arity, currentArity);
        } else if (r == L3Role.RETURN) {
            emitNestedReturn(mv, expr, map, arity, currentArity);
        } else if (r == L3Role.WHILE) {
            throw new IllegalArgumentException("WHILE not allowed in value context");
        } else if (r == L3Role.BREAK) {
            throw new IllegalArgumentException("BREAK not allowed in value context");
        } else if (r == L3Role.CONTINUE) {
            throw new IllegalArgumentException("CONTINUE not allowed in value context");
        } else if (r == L3Role.REDO) {
            throw new IllegalArgumentException("REDO not allowed in value context");
        } else if (r == L3Role.LOOP_LABEL) {
            throw new IllegalArgumentException("LOOP_LABEL not allowed in value context");
        } else if (r == L3Role.RETRY_LABEL) {
            throw new IllegalArgumentException("RETRY_LABEL not allowed in value context");
        } else if (r == L3Role.RETRYABLE) {
            throw new IllegalArgumentException("RETRYABLE not allowed in value context");
        } else if (r == L3Role.RETRY) {
            throw new IllegalArgumentException("RETRY not allowed in value context");
        } else if (r == L3Role.FIELD_FOLLOW) {
            emitOccurrence(mv, expr.child(0));
            mv.visitLdcInsn(Integer.valueOf(expr.intPayload));
            mv.visitMethodInsn(INVOKEVIRTUAL, "lmx/LmxOccurrence", "child", "(I)Ljava/lang/Object;", false);
            mv.visitTypeInsn(CHECKCAST, "java/lang/Integer");
            mv.visitMethodInsn(INVOKEVIRTUAL, "java/lang/Integer", "intValue", "()I", false);
        } else if (r == L3Role.ADD) {
            emitIntExpr(mv, expr.child(0), map, arity, currentArity);
            emitIntExpr(mv, expr.child(1), map, arity, currentArity);
            mv.visitInsn(IADD);
        } else if (r == L3Role.CALL) {
            emitOccurrence(mv, expr.child(1));
            for (int i = 2; i < expr.childCount(); i++) {
                emitIntExpr(mv, expr.child(i), map, arity, currentArity);
            }
            L3Node callee = expr.child(0);
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
            emitIntExpr(mv, expr.child(0), map, arity, currentArity);
            mv.visitJumpInsn(IFEQ, elseL);
            emitIntExpr(mv, expr.child(1), map, arity, currentArity);
            mv.visitJumpInsn(GOTO, endL);
            mv.visitLabel(elseL);
            emitIntExpr(mv, expr.child(2), map, arity, currentArity);
            mv.visitLabel(endL);
        } else if (r == L3Role.SUBJECT_REF) {
            throw new IllegalArgumentException("SUBJECT_REF is not an int expression");
        } else {
            throw new IllegalArgumentException("unsupported role");
        }
    }

    private static void emitStmt(
            MethodVisitor mv,
            L3Node expr,
            Map<L3Node, Integer> map,
            Map<L3Node, Integer> arity,
            int currentArity) {
        L3Role r = expr.role;
        if (r == L3Role.RETURN) {
            emitNestedReturn(mv, expr, map, arity, currentArity);
            return;
        }
        if (r == L3Role.BREAK || r == L3Role.CONTINUE || r == L3Role.REDO) {
            Label[] frame;
            if (expr.childCount() == 0) {
                frame = LOOP_STACK.get().peekFirst();
            } else {
                L3Node lab = expr.child(0);
                frame = LABEL_FRAMES.get().get(lab);
                if (frame == null) {
                    throw new IllegalArgumentException("loop label not visible in this CALLABLE");
                }
            }
            int idx = r == L3Role.CONTINUE ? 0 : (r == L3Role.BREAK ? 1 : 2);
            mv.visitJumpInsn(GOTO, frame[idx]);
            return;
        }
        if (r == L3Role.RETRY) {
            Label target;
            if (expr.childCount() == 0) {
                target = RETRY_STACK.get().peekFirst();
                if (target == null) {
                    throw new IllegalArgumentException("RETRY outside region");
                }
            } else {
                L3Node lab = expr.child(0);
                target = RETRY_LABEL_FRAMES.get().get(lab);
                if (target == null) {
                    throw new IllegalArgumentException("retry label not visible in this CALLABLE");
                }
            }
            mv.visitJumpInsn(GOTO, target);
            return;
        }
        if (r == L3Role.RETRYABLE) {
            emitRetryable(mv, expr, map, arity, currentArity);
            return;
        }
        if (r == L3Role.WHILE) {
            emitWhile(mv, expr, map, arity, currentArity);
            return;
        }
        if (r == L3Role.SEQUENCE) {
            for (int i = 0; i < expr.childCount(); i++) {
                emitStmt(mv, expr.child(i), map, arity, currentArity);
            }
            return;
        }
        if (r == L3Role.IF) {
            Label elseL = new Label();
            Label endL = new Label();
            emitIntExpr(mv, expr.child(0), map, arity, currentArity);
            mv.visitJumpInsn(IFEQ, elseL);
            emitStmt(mv, expr.child(1), map, arity, currentArity);
            mv.visitJumpInsn(GOTO, endL);
            mv.visitLabel(elseL);
            emitStmt(mv, expr.child(2), map, arity, currentArity);
            mv.visitLabel(endL);
            return;
        }
        emitIntExpr(mv, expr, map, arity, currentArity);
        mv.visitInsn(POP);
    }


    /** Evaluate RETURN value once and IRETURN from the current CALLABLE method. */
    private static void emitNestedReturn(
            MethodVisitor mv,
            L3Node expr,
            Map<L3Node, Integer> map,
            Map<L3Node, Integer> arity,
            int currentArity) {
        if (expr.childCount() != 1) {
            throw new IllegalArgumentException("RETURN arity: need exactly one value");
        }
        emitIntExpr(mv, expr.child(0), map, arity, currentArity);
        mv.visitInsn(IRETURN);
    }

    private static void emitWhile(
            MethodVisitor mv,
            L3Node expr,
            Map<L3Node, Integer> map,
            Map<L3Node, Integer> arity,
            int currentArity) {
        // frame[0]=cond (CONTINUE), frame[1]=exit (BREAK), frame[2]=body entry (REDO)
        Label cond = new Label();
        Label done = new Label();
        Label body = new Label();
        Label[] frame = new Label[] {cond, done, body};
        L3Node lab = expr.childCount() == 3 ? expr.child(2) : null;
        LOOP_STACK.get().addFirst(frame);
        if (lab != null) {
            LABEL_FRAMES.get().put(lab, frame);
        }
        try {
            mv.visitLabel(cond);
            emitIntExpr(mv, expr.child(0), map, arity, currentArity);
            mv.visitJumpInsn(IFEQ, done);
            mv.visitLabel(body);
            emitStmt(mv, expr.child(1), map, arity, currentArity);
            mv.visitJumpInsn(GOTO, cond);
            mv.visitLabel(done);
        } finally {
            if (lab != null) {
                LABEL_FRAMES.get().remove(lab);
            }
            LOOP_STACK.get().removeFirst();
        }
    }

    private static void emitRetryable(
            MethodVisitor mv,
            L3Node expr,
            Map<L3Node, Integer> map,
            Map<L3Node, Integer> arity,
            int currentArity) {
        // RETRY jumps to body entry; no new activation / no local or probe rollback.
        Label body = new Label();
        L3Node lab = expr.childCount() == 2 ? expr.child(1) : null;
        RETRY_STACK.get().addFirst(body);
        if (lab != null) {
            RETRY_LABEL_FRAMES.get().put(lab, body);
        }
        try {
            mv.visitLabel(body);
            emitStmt(mv, expr.child(0), map, arity, currentArity);
        } finally {
            if (lab != null) {
                RETRY_LABEL_FRAMES.get().remove(lab);
            }
            RETRY_STACK.get().removeFirst();
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
        if (entry == null || entry.role != L3Role.CALLABLE) {
            throw new IllegalArgumentException("expected CALLABLE root");
        }
        requireSealed(entry);
        LOOP_DEPTH.set(Integer.valueOf(0));
        LOOP_STACK.get().clear();
        ACTIVE_LOOP_LABELS.get().clear();
        LABEL_FRAMES.get().clear();
        RETRY_DEPTH.set(Integer.valueOf(0));
        RETRY_STACK.get().clear();
        ACTIVE_RETRY_LABELS.get().clear();
        RETRY_LABEL_FRAMES.get().clear();
        List<L3Node> order = new ArrayList<L3Node>();
        Map<L3Node, Integer> map = new IdentityHashMap<L3Node, Integer>();
        collectCallables(entry, order, map);
        Map<L3Node, Integer> arity = new IdentityHashMap<L3Node, Integer>();
        Map<L3Node, Integer> slots = new IdentityHashMap<L3Node, Integer>();
        for (L3Node c : order) {
            arity.put(c, Integer.valueOf(computeArity(c)));
            slots.put(c, Integer.valueOf(computeSlotCount(c)));
        }
        validateAll(order, map, arity, slots);
        List<String> names = new ArrayList<String>();
        for (int i = 0; i < order.size(); i++) {
            names.add("c" + i);
        }
        names.add(EVAL);
        return names;
    }
}
