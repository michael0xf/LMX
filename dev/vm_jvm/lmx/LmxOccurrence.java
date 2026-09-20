package lmx;

import java.util.IdentityHashMap;
import java.util.Map;

/**
 * Isolated JVM ABI for an Lmx occurrence {@code {node, len, data}}.
 *
 * <p>{@code node} is the physical reference to the lexical parent occurrence,
 * or {@code null} for an independent root ({@code node = 0} in the native model).
 * It is not a kind/type tag (see docs/LMX_semantics.en.md ?3, ?8, ?9).
 *
 * <p>{@code merge} copies the used mutable graph into a new root with one
 * source-to-copy identity map: shared mutable targets stay shared, {@code node}
 * links are rewritten into the copy, operands are unchanged. Admitted terminals
 * ({@link LmxTerminal}) and non-occurrence leaves keep identity
 * (docs/LMX_semantics.en.md ?19, ?22).
 */
public final class LmxOccurrence {
    /** Lexical parent occurrence, or {@code null} if independent. */
    private final LmxOccurrence node;
    private final Object[] data;

    private LmxOccurrence(LmxOccurrence node, Object[] data) {
        if (data == null) {
            throw new IllegalArgumentException("data");
        }
        this.node = node;
        this.data = data;
    }

    /** Independent root: {@code node == null}. */
    public static LmxOccurrence independent(Object... fields) {
        LmxOccurrence root = new LmxOccurrence(null, copyFields(fields));
        bindNestedParents(root);
        return root;
    }

    /** Nested occurrence whose lexical parent is exactly {@code parent}. */
    public static LmxOccurrence nested(LmxOccurrence parent, Object... fields) {
        if (parent == null) {
            throw new IllegalArgumentException("parent");
        }
        LmxOccurrence o = new LmxOccurrence(parent, copyFields(fields));
        bindNestedParents(o);
        return o;
    }

    public LmxOccurrence node() {
        return node;
    }

    public int len() {
        return data.length;
    }

    public Object child(int index) {
        checkBounds(index);
        return data[index];
    }

    /** Assignment writes {@code data[index]}, never {@code len}. */
    public void setChild(int index, Object value) {
        checkBounds(index);
        data[index] = value;
    }

    /**
     * Graph-copy merge (?19): fresh independent root; direct fields = operand
     * fields in order; mutable {@link LmxOccurrence} graph copied via identity map;
     * {@link LmxTerminal} and other non-occurrence leaves shared by identity.
     * New root {@code node} is {@code null} (isolated expression / zero parent).
     */
    public static LmxOccurrence merge(LmxOccurrence... parts) {
        if (parts == null || parts.length == 0) {
            throw new IllegalArgumentException("parts");
        }
        int n = 0;
        for (LmxOccurrence p : parts) {
            if (p == null) {
                throw new IllegalArgumentException("null part");
            }
            n += p.len();
        }
        Map<LmxOccurrence, LmxOccurrence> map = new IdentityHashMap<LmxOccurrence, LmxOccurrence>();
        Object[] fields = new Object[n];
        LmxOccurrence root = new LmxOccurrence(null, fields);
        int k = 0;
        for (LmxOccurrence p : parts) {
            for (int i = 0; i < p.len(); i++) {
                fields[k++] = copyRef(p.child(i), map, root);
            }
        }
        return root;
    }

    private static Object copyRef(Object value, Map<LmxOccurrence, LmxOccurrence> map, LmxOccurrence container) {
        if (value instanceof LmxOccurrence) {
            return copyOccurrence((LmxOccurrence) value, map, container);
        }
        // Leaves and admitted terminals: share identity (primitives, LmxTerminal, ?).
        return value;
    }

    private static LmxOccurrence copyOccurrence(
            LmxOccurrence src, Map<LmxOccurrence, LmxOccurrence> map, LmxOccurrence parentForCopy) {
        LmxOccurrence existing = map.get(src);
        if (existing != null) {
            return existing;
        }
        Object[] data = new Object[src.len()];
        LmxOccurrence dst = new LmxOccurrence(parentForCopy, data);
        map.put(src, dst);
        for (int i = 0; i < src.len(); i++) {
            data[i] = copyRef(src.child(i), map, dst);
        }
        return dst;
    }

    /** Nested mutable children in {@code data} get {@code node == container}. */
    private static void bindNestedParents(LmxOccurrence container) {
        Map<LmxOccurrence, LmxOccurrence> rebound = new IdentityHashMap<LmxOccurrence, LmxOccurrence>();
        for (int i = 0; i < container.data.length; i++) {
            Object c = container.data[i];
            if (c instanceof LmxOccurrence) {
                LmxOccurrence child = (LmxOccurrence) c;
                if (child.node == container) {
                    continue;
                }
                LmxOccurrence fixed = rebound.get(child);
                if (fixed == null) {
                    fixed = reparent(child, container);
                    rebound.put(child, fixed);
                }
                container.data[i] = fixed;
            }
        }
    }

    private static LmxOccurrence reparent(LmxOccurrence src, LmxOccurrence newParent) {
        Object[] data = new Object[src.len()];
        System.arraycopy(src.data, 0, data, 0, src.len());
        LmxOccurrence o = new LmxOccurrence(newParent, data);
        bindNestedParents(o);
        return o;
    }

    private static Object[] copyFields(Object[] fields) {
        Object[] copy = new Object[fields.length];
        System.arraycopy(fields, 0, copy, 0, fields.length);
        return copy;
    }

    private void checkBounds(int index) {
        if (index < 0 || index >= data.length) {
            throw new IndexOutOfBoundsException(
                    "LmxOccurrence index " + index + " not in [0," + data.length + ")");
        }
    }
}
